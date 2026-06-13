// data_settings_screen_test.dart
// データ同期設定（モバイル）の widget テスト。
// settings_desktop_view_test の _DataSection テストと同じ観点:
// トグル ON → 即時バックアップ / 復元ダイアログ → 適用 / 利用不可エラー。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/settings/presentation/data_settings_screen.dart';
import 'package:tsukaikiri/features/sync/service/sync_service.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

class _FakeSyncService implements SyncService {
  bool available = true;
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
  late _FakeSyncService sync;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sync = _FakeSyncService();
  });

  tearDown(() async => db.close());

  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          syncServiceProvider.overrideWithValue(sync),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DataSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
        tester.element(find.byType(DataSettingsScreen)));
  }

  /// SnackBar タイマーを消化してからアンマウントする。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('トグル ON で即時バックアップされ成功スナックバーが出る', (tester) async {
    final container = await pumpScreen(tester);

    // 先頭の Switch が iCloud 自動バックアップ（他に詳細トグルが2つある）。
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(sync.writeCount, 1);
    expect(find.text('バックアップしました。'), findsOneWidget);

    final settings = await container.read(settingsRepositoryProvider).get();
    expect(settings.syncEnabled, isTrue);

    await unmountApp(tester);
  });

  testWidgets('syncKeepOnFailure=false: ON で失敗するとトグルが OFF に戻る',
      (tester) async {
    sync.available = false; // 即時バックアップが失敗する
    final container = await pumpScreen(tester);
    await container.read(settingsRepositoryProvider).setSyncKeepOnFailure(false);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final settings = await container.read(settingsRepositoryProvider).get();
    expect(settings.syncEnabled, isFalse); // 失敗で巻き戻る
    await unmountApp(tester);
  });

  testWidgets('既定(keep=true): 失敗してもトグルは ON のまま', (tester) async {
    sync.available = false; // 即時バックアップが失敗する
    final container = await pumpScreen(tester);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final settings = await container.read(settingsRepositoryProvider).get();
    expect(settings.syncEnabled, isTrue); // keep=true なので維持
    await unmountApp(tester);
  });

  testWidgets('iCloud 利用不可: バックアップでエラースナックバーが出る', (tester) async {
    sync.available = false;
    await pumpScreen(tester);

    await tester.tap(find.text('今すぐバックアップ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('iCloud が利用できません'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('復元: 確認ダイアログ→復元するで在庫が置き換わる', (tester) async {
    final container = await pumpScreen(tester);

    // 設定行を作っておく（バックアップは設定行が必要）。
    await container.read(settingsRepositoryProvider).setSyncEnabled(false);

    final repo = container.read(inventoryRepositoryProvider);
    await repo.save(Ingredient(
      id: 'milk-1',
      name: '牛乳',
      normalizedName: 'milk',
      category: IngredientCategory.dairy,
      quantity: 1,
      unit: '本',
      expiryDate: null,
      updatedAt: DateTime.now(),
    ));
    await repo.save(Ingredient(
      id: 'tofu-1',
      name: '豆腐',
      normalizedName: 'tofu',
      category: IngredientCategory.other,
      quantity: 1,
      unit: '個',
      expiryDate: null,
      updatedAt: DateTime.now(),
    ));
    // 2件の状態でバックアップを作る。
    await tester.tap(find.text('今すぐバックアップ'));
    await tester.pumpAndSettle();
    expect(sync.writeCount, 1);
    // バックアップ成功スナックバーを消化する（次のスナックバーが詰まるため）。
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // 牛乳を消して1件にする。
    await repo.deleteById('milk-1');
    expect((await repo.getInventory()).length, 1);

    // 復元 → ダイアログに件数が出る → 復元する。
    await tester.tap(find.text('バックアップから復元'));
    await tester.pumpAndSettle();
    expect(find.text('バックアップの在庫: 2件'), findsOneWidget);

    await tester.tap(find.text('復元する'));
    await tester.pumpAndSettle();

    final restored = await repo.getInventory();
    expect(restored.length, 2);
    expect(find.text('復元しました。'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('バックアップ未存在: 復元でエラースナックバーが出る', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('バックアップから復元'));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('バックアップが見つかりませんでした'), findsOneWidget);

    await unmountApp(tester);
  });
}
