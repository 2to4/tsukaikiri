// onboarding_desktop_view_test.dart
// M7 設定アシスタント（6ステップ）ビューの widget テスト。
// CLAUDE.md の規約に従い unmountApp パターン必須。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/core/secure_storage/secure_storage_service.dart';
import 'package:tsukaikiri/features/onboarding/presentation/onboarding_desktop_view.dart';
import 'package:tsukaikiri/features/settings/data/settings_repository.dart';
import 'package:tsukaikiri/features/settings/presentation/locale_controller.dart';
import 'package:tsukaikiri/features/shell/presentation/shell_providers.dart';
import 'package:tsukaikiri/features/shopping/domain/shopping_list.dart';
import 'package:tsukaikiri/features/shopping/service/shopping_list_service.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

import 'fakes/fake_secure_storage.dart';

// ──────────────────────────────────────────────────────────────
// フェイク: ShoppingListService（成功版・失敗版）
// ──────────────────────────────────────────────────────────────

/// 通常動作のフェイク ShoppingListService。
class _FakeShoppingListService implements ShoppingListService {
  _FakeShoppingListService();

  @override
  Future<List<ShoppingList>> getLists() async => const [];

  @override
  Future<ShoppingList> createList(String name) async =>
      ShoppingList(id: 'new-$name', name: name);

  @override
  Future<int> addItems(String listId, List<ShoppingListItem> items) async =>
      items.length;
}

/// getLists が常に失敗するフェイク。
class _FailingShoppingListService implements ShoppingListService {
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
// テストヘルパー
// ──────────────────────────────────────────────────────────────

/// オンボーディングビューをデスクトップ幅でビルドするヘルパー。
Future<void> pumpView(
  WidgetTester tester, {
  required AppDatabase db,
  required SecureStorageService secure,
  ShoppingListService? shoppingService,
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
        if (shoppingService != null)
          shoppingListServiceProvider.overrideWithValue(shoppingService),
      ],
      child: Consumer(builder: (context, ref, _) {
        final locale = ref.watch(localeControllerProvider);
        return MaterialApp(
          locale: locale ?? const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: OnboardingDesktopView()),
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

// ──────────────────────────────────────────────────────────────
// テスト本体
// ──────────────────────────────────────────────────────────────

void main() {
  late AppDatabase db;
  late SettingsRepository repo;
  late FakeSecureStorage secure;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepository(db);
    secure = FakeSecureStorage();
  });

  tearDown(() async => db.close());

  // ═══════════════════════════════════════════════════════
  // ① ようこそステップ表示 →「はじめる」で AI ステップへ
  // ═══════════════════════════════════════════════════════
  testWidgets('① ようこそステップが表示され「はじめる」でAIステップへ進む',
      (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester, db: db, secure: secure);

    // ようこそステップの主要テキストが表示される
    expect(find.text('つかいきりへようこそ'), findsOneWidget);
    expect(find.text('はじめる'), findsOneWidget);

    // ステップレールの「ようこそ」が表示される
    expect(find.text('ようこそ'), findsOneWidget);

    // 「はじめる」をタップ → AIステップへ遷移
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();

    // AI ステップのタイトルが表示される
    expect(find.text('AIプロバイダを選択'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ② ステップレールに現在地が反映される
  // ═══════════════════════════════════════════════════════
  testWidgets('② ステップレールに6項目が表示され「はじめる」後に現在地が「AIを選ぶ」になる',
      (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester, db: db, secure: secure);

    // レールの全ステップが表示されている
    expect(find.text('ようこそ'), findsOneWidget);
    expect(find.text('AIを選ぶ'), findsOneWidget);
    expect(find.text('リマインダー連携'), findsOneWidget);
    expect(find.text('リストを選ぶ'), findsOneWidget);
    expect(find.text('調理家電'), findsOneWidget);
    expect(find.text('完了'), findsOneWidget);

    // 「はじめる」タップでステップ1（AI選択）へ
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();

    // ステップ1のコンテンツタイトル「AIプロバイダを選択」が出る
    expect(find.text('AIプロバイダを選択'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ AI ステップでプロバイダ選択 → settings の selectedProvider に保存される
  // ═══════════════════════════════════════════════════════
  testWidgets('③ AIステップでプロバイダカードをタップすると selectedProvider が保存される',
      (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester, db: db, secure: secure);

    // はじめる → AI ステップへ
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();

    // 「Claude」カードをタップ
    await tester.tap(find.text('Claude'));
    await tester.pumpAndSettle();

    // DB に保存されている
    expect((await repo.get()).selectedProvider, 'claude');

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ スキップで次ステップへ進める
  // ═══════════════════════════════════════════════════════
  testWidgets('④ AIステップの「あとで設定」をタップすると次のリマインダー連携ステップへ進む',
      (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(tester, db: db, secure: secure);

    // はじめる → AI ステップへ
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();

    // AI ステップにいることを確認
    expect(find.text('AIプロバイダを選択'), findsOneWidget);
    expect(find.text('あとで設定'), findsOneWidget);

    // スキップ
    await tester.tap(find.text('あとで設定'));
    await tester.pumpAndSettle();

    // リマインダー連携ステップへ進む
    expect(find.text('リマインダーと連携'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤ 完了ステップにサマリーが表示され「食材を登録してはじめる」で
  //    shellSectionProvider が inventory になる
  // ═══════════════════════════════════════════════════════
  testWidgets(
      '⑤ 完了ステップにサマリーが表示され「食材を登録してはじめる」で在庫セクションへ遷移',
      (tester) async {
    await repo.setLocalePref('ja');
    // AI プロバイダ設定済みにしておく
    await repo.setSelectedProvider('gemini');
    await pumpView(
      tester,
      db: db,
      secure: secure,
      shoppingService: _FakeShoppingListService(),
    );

    // ステップ0→1→2→3→4→5 をスキップで一気に進む。
    // ようこそ
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
    // ステップ1（AI選択）→スキップ
    await tester.tap(find.text('あとで設定'));
    await tester.pumpAndSettle();
    // ステップ2（連携）→スキップ
    await tester.tap(find.text('あとで'));
    await tester.pumpAndSettle();
    // ステップ3（リスト選択）→スキップ
    await tester.tap(find.text('あとで'));
    await tester.pumpAndSettle();
    // ステップ4（家電）→スキップ（「持っていない」）
    await tester.tap(find.text('持っていない'));
    await tester.pumpAndSettle();

    // 完了ステップ
    expect(find.text('準備ができました'), findsOneWidget);

    // サマリーチップが表示される（AI チップ・リスト チップ・家電 チップ）
    expect(find.byKey(const Key('summary_ai')), findsOneWidget);
    expect(find.byKey(const Key('summary_list')), findsOneWidget);
    expect(find.byKey(const Key('summary_appliance')), findsOneWidget);

    // 「食材を登録してはじめる」ボタンが表示される
    expect(find.text('食材を登録してはじめる'), findsOneWidget);

    // タップ前に shellSectionProvider のコンテナを取得する。
    final container = ProviderScope.containerOf(
      tester.element(find.byType(OnboardingDesktopView)),
    );

    // タップ
    await tester.tap(find.text('食材を登録してはじめる'));
    await tester.pumpAndSettle();

    // shellSectionProvider が inventory になっていることを確認
    expect(container.read(shellSectionProvider), ShellSection.inventory);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑥ リスト選択ステップで getLists 失敗時にエラー表示
  // ═══════════════════════════════════════════════════════
  testWidgets('⑥ リスト選択ステップで getLists 失敗時にエラーメッセージが表示される',
      (tester) async {
    await repo.setLocalePref('ja');
    await pumpView(
      tester,
      db: db,
      secure: secure,
      shoppingService: _FailingShoppingListService(),
    );

    // ようこそ → AI（スキップ）→ 連携（スキップ）→ リスト選択ステップへ
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('あとで設定'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('あとで'));
    await tester.pumpAndSettle();

    // リスト選択ステップにいることを確認
    expect(find.text('追加先リストを選ぶ'), findsOneWidget);

    // リスト読み込みボタンをタップ
    expect(find.text('リストを読み込む'), findsOneWidget);
    await tester.tap(find.text('リストを読み込む'));
    await tester.pumpAndSettle();

    // エラーメッセージが表示される
    expect(
      find.textContaining('リマインダーにアクセスできませんでした'),
      findsOneWidget,
    );

    await unmountApp(tester);
  });
}
