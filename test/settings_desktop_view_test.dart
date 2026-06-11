// settings_desktop_view_test.dart
// M3 設定 2ペインビューの widget テスト。
// CLAUDE.md の規約に従い unmountApp パターン必須。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/core/secure_storage/secure_storage_service.dart';
import 'package:tsukaikiri/features/settings/data/settings_repository.dart';
import 'package:tsukaikiri/features/settings/presentation/locale_controller.dart';
import 'package:tsukaikiri/features/settings/presentation/settings_desktop_view.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/shopping/domain/shopping_list.dart';
import 'package:tsukaikiri/features/shopping/service/shopping_list_service.dart';
import 'package:tsukaikiri/features/sync/domain/backup_codec.dart';
import 'package:tsukaikiri/features/sync/service/sync_service.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

// ──────────────────────────────────────────────────────────────
// フェイク: SecureStorageService（インメモリ）
// ──────────────────────────────────────────────────────────────
class _FakeSecureStorage extends SecureStorageService {
  _FakeSecureStorage() : super();
  final Map<String, String> _store = {};

  @override
  Future<String?> getApiKey(String provider) async => _store[provider];

  @override
  Future<void> setApiKey(String provider, String apiKey) async =>
      _store[provider] = apiKey;

  @override
  Future<void> deleteApiKey(String provider) async => _store.remove(provider);

  @override
  Future<bool> hasApiKey(String provider) async {
    final k = _store[provider];
    return k != null && k.isNotEmpty;
  }
}

// ──────────────────────────────────────────────────────────────
// フェイク: ShoppingListService（getLists が常に失敗する版・成功版）
// ──────────────────────────────────────────────────────────────
class _FailingShoppingService implements ShoppingListService {
  @override
  Future<List<ShoppingList>> getLists() async =>
      throw Exception('platform channel unavailable');

  @override
  Future<ShoppingList> createList(String name) async =>
      throw Exception('platform channel unavailable');

  @override
  Future<int> addItems(String listId, List<ShoppingListItem> items) async => 0;
}

// ──────────────────────────────────────────────────────────────
// フェイク: SyncService（インメモリ・可用性切替可能）
// ──────────────────────────────────────────────────────────────
class _FakeSyncService implements SyncService {
  _FakeSyncService({this.available = true, this.storedBackup});

  bool available;
  String? storedBackup;
  int writeCount = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> writeBackup(String payload) async {
    writeCount++;
    storedBackup = payload;
  }

  @override
  Future<String?> readBackup() async => storedBackup;
}

void main() {
  late AppDatabase db;
  late SettingsRepository repo;
  late _FakeSecureStorage secure;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
    secure = _FakeSecureStorage();
  });

  tearDown(() async => db.close());

  Future<void> pumpView(
    WidgetTester tester, {
    bool failShopping = false,
    SyncService? syncService,
  }) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          secureStorageProvider.overrideWithValue(secure),
          if (failShopping)
            shoppingListServiceProvider
                .overrideWithValue(_FailingShoppingService()),
          if (syncService != null)
            syncServiceProvider.overrideWithValue(syncService),
        ],
        child: Consumer(builder: (context, ref, _) {
          final locale = ref.watch(localeControllerProvider);
          return MaterialApp(
            locale: locale ?? const Locale('ja'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: SettingsDesktopView()),
          );
        }),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// drift の stream 購読解除が Timer(0) を予約するため、各テストの最後に
  /// 画面をアンマウントしてタイマーを消化させる。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  // ═══════════════════════════════════════════════════════
  // ① セクションナビ切替
  // ═══════════════════════════════════════════════════════
  testWidgets('セクションナビをタップするとコンテンツが切り替わる', (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester);

    // 初期は AI セクション
    expect(find.text('AI（食材認識・献立提案）'), findsOneWidget);

    // 「一般」へ切替
    await tester.tap(find.text('一般'));
    await tester.pumpAndSettle();
    expect(find.text('日本語'), findsWidgets);

    // 「データ」へ切替
    await tester.tap(find.text('データ'));
    await tester.pumpAndSettle();
    expect(find.text('データ同期'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ② プロバイダカード選択で selectedProvider が保存される
  // ═══════════════════════════════════════════════════════
  testWidgets('プロバイダカードをタップすると selectedProvider が保存される',
      (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester);

    // 既定は gemini
    expect((await repo.get()).selectedProvider, 'gemini');

    // Claude カードをタップ
    await tester.tap(find.text('Claude'));
    await tester.pumpAndSettle();

    expect((await repo.get()).selectedProvider, 'claude');

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ APIキー保存で SecureStorage に書かれマスク表示になる
  // ═══════════════════════════════════════════════════════
  testWidgets('APIキーを入力して保存するとマスク表示に変わる', (tester) async {
    await repo.setLocalePref('ja');
    await repo.setSelectedProvider('claude');
    await pumpView(tester);

    // 入力欄が出ている（未登録）
    final field = find.byType(TextField).first;
    await tester.enterText(field, 'sk-ant-test-key-abcd');
    await tester.pumpAndSettle();

    // 保存ボタン
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // SecureStorage に書かれている
    expect(await secure.getApiKey('claude'), 'sk-ant-test-key-abcd');

    // マスク表示に切り替わる（「変更」「削除」が出る）
    expect(find.text('変更'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ 言語切替が動く
  // ═══════════════════════════════════════════════════════
  testWidgets('一般セクションで English を選ぶと保存され UI が英語になる',
      (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester);

    await tester.tap(find.text('一般'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // DB に保存される
    expect((await repo.get()).localePref, 'en');
    // ナビ・見出しが英語表記に切り替わる（ナビと見出しの両方で出る）
    expect(find.text('General'), findsWidgets);
    expect(find.text('System default'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤ データセクションが準備中表示
  // ═══════════════════════════════════════════════════════
  testWidgets('データセクションは iCloud 自動バックアップと操作ボタンを表示する', (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester);

    await tester.tap(find.text('データ'));
    await tester.pumpAndSettle();

    expect(find.text('iCloud 自動バックアップ'), findsOneWidget);
    expect(find.text('今すぐバックアップ'), findsOneWidget);
    expect(find.text('バックアップから復元'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑥ 買い物リスト読込が失敗するとエラー表示になる
  // ═══════════════════════════════════════════════════════
  testWidgets('買い物リスト読込が失敗するとエラーメッセージを表示する',
      (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester, failShopping: true);

    await tester.tap(find.text('買い物リスト'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('リストを読み込む'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('リストを取得できませんでした'),
      findsOneWidget,
    );

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑦ 今すぐバックアップ（成功）
  // ═══════════════════════════════════════════════════════
  testWidgets('今すぐバックアップが成功すると完了表示と日時が更新される', (tester) async {
    await repo.setLocalePref('ja');
    final sync = _FakeSyncService();
    await pumpView(tester, syncService: sync);

    await tester.tap(find.text('データ'));
    await tester.pumpAndSettle();
    expect(find.text('バックアップ未実施'), findsOneWidget);

    await tester.tap(find.text('今すぐバックアップ'));
    await tester.pumpAndSettle();

    expect(find.text('バックアップしました。'), findsOneWidget);
    expect(sync.writeCount, 1);
    // API キーがバックアップに含まれないこと（i18n 規約と並ぶ重要要件）
    expect(sync.storedBackup, isNot(contains('apiKey')));
    expect(find.text('バックアップ未実施'), findsNothing);
    expect(find.textContaining('最終バックアップ:'), findsOneWidget);

    // SnackBar の自動クローズタイマーを消化してから後始末
    await tester.pump(const Duration(seconds: 5));
    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑧ 今すぐバックアップ（iCloud 不可）
  // ═══════════════════════════════════════════════════════
  testWidgets('iCloud が利用できないとエラーメッセージを表示する', (tester) async {
    await repo.setLocalePref('ja');
    final sync = _FakeSyncService(available: false);
    await pumpView(tester, syncService: sync);

    await tester.tap(find.text('データ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('今すぐバックアップ'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('iCloud が利用できません'),
      findsOneWidget,
    );
    expect(sync.writeCount, 0);

    await tester.pump(const Duration(seconds: 5));
    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑨ 復元（確認ダイアログ → 在庫置換）
  // ═══════════════════════════════════════════════════════
  testWidgets('復元は確認ダイアログを経て在庫を置き換える', (tester) async {
    await repo.setLocalePref('ja');
    final invRepo = InventoryRepository(db);
    await invRepo.save(Ingredient(
      id: 'before-1',
      name: '牛乳',
      normalizedName: 'milk',
      category: IngredientCategory.dairy,
      quantity: 1,
      unit: '本',
      expiryDate: null,
      updatedAt: DateTime.now(),
    ));

    // バックアップ側は豆腐1件
    final row = await repo.getRow();
    final payload = BackupCodec.encodeBackup(
      ingredients: [
        Ingredient(
          id: 'backup-1',
          name: '豆腐',
          normalizedName: 'tofu',
          category: IngredientCategory.other,
          quantity: 1,
          unit: '個',
          expiryDate: null,
          updatedAt: DateTime.now(),
        ),
      ],
      settings: row!,
    );
    final sync = _FakeSyncService(storedBackup: payload);
    await pumpView(tester, syncService: sync);

    await tester.tap(find.text('データ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('バックアップから復元'));
    await tester.pumpAndSettle();

    // 確認ダイアログ（件数つき）
    expect(find.text('バックアップを復元しますか？'), findsOneWidget);
    expect(find.text('バックアップの在庫: 1件'), findsOneWidget);

    await tester.tap(find.text('復元する'));
    await tester.pumpAndSettle();

    expect(find.text('復元しました。'), findsOneWidget);
    final inv = await invRepo.getInventory();
    expect(inv, hasLength(1));
    expect(inv.single.name, '豆腐');

    await tester.pump(const Duration(seconds: 5));
    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑩ 復元キャンセルでは何も変わらない
  // ═══════════════════════════════════════════════════════
  testWidgets('復元の確認ダイアログをキャンセルすると在庫は変わらない', (tester) async {
    await repo.setLocalePref('ja');
    final invRepo = InventoryRepository(db);
    await invRepo.save(Ingredient(
      id: 'before-1',
      name: '牛乳',
      normalizedName: 'milk',
      category: IngredientCategory.dairy,
      quantity: 1,
      unit: '本',
      expiryDate: null,
      updatedAt: DateTime.now(),
    ));

    final row = await repo.getRow();
    final payload = BackupCodec.encodeBackup(
      ingredients: const [],
      settings: row!,
    );
    final sync = _FakeSyncService(storedBackup: payload);
    await pumpView(tester, syncService: sync);

    await tester.tap(find.text('データ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('バックアップから復元'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    final inv = await invRepo.getInventory();
    expect(inv, hasLength(1));
    expect(inv.single.name, '牛乳');

    await unmountApp(tester);
  });
}
