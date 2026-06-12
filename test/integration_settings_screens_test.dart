// integration_settings_screens_test.dart
// 連携設定（買い物リスト・調理家電）モバイル画面の widget テスト。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/settings/domain/appliance.dart';
import 'package:tsukaikiri/features/settings/presentation/integration_settings_screens.dart';
import 'package:tsukaikiri/features/shopping/domain/shopping_list.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

import 'shopping_desktop_view_test.dart' show FakeShoppingListService;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    FakeShoppingListService? shopping,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          if (shopping != null)
            shoppingListServiceProvider.overrideWithValue(shopping),
        ],
        child: MaterialApp(
          locale: const Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
  }

  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  group('ShoppingSettingsScreen', () {
    testWidgets('読み込み→一覧表示→選択で設定に保存される', (tester) async {
      final service = FakeShoppingListService(lists: const [
        ShoppingList(id: 'a', name: '買い物'),
        ShoppingList(id: 'b', name: '日用品'),
      ]);
      final container =
          await pumpScreen(tester, const ShoppingSettingsScreen(),
              shopping: service);

      await tester.tap(find.text('リストを読み込む'));
      await tester.pumpAndSettle();

      expect(find.text('買い物'), findsOneWidget);
      expect(find.text('日用品'), findsOneWidget);

      await tester.tap(find.text('日用品'));
      await tester.pumpAndSettle();

      final settings =
          await container.read(settingsRepositoryProvider).get();
      expect(settings.shoppingListId, 'b');
      expect(settings.shoppingListName, '日用品');

      await unmountApp(tester);
    });

    testWidgets('読み込み失敗でエラーメッセージが出る', (tester) async {
      final service = FakeShoppingListService(getListsFail: true);
      await pumpScreen(tester, const ShoppingSettingsScreen(),
          shopping: service);

      await tester.tap(find.text('リストを読み込む'));
      await tester.pumpAndSettle();

      expect(find.textContaining('リストを取得できませんでした'), findsOneWidget);

      await unmountApp(tester);
    });

    testWidgets('新規作成でリストが作られ選択状態になる', (tester) async {
      final service = FakeShoppingListService();
      final container =
          await pumpScreen(tester, const ShoppingSettingsScreen(),
              shopping: service);

      await tester.enterText(find.byType(TextField), '新しい買い物');
      await tester.tap(find.text('作成'));
      await tester.pumpAndSettle();

      final settings =
          await container.read(settingsRepositoryProvider).get();
      expect(settings.shoppingListName, '新しい買い物');

      await unmountApp(tester);
    });
  });

  group('ApplianceSettingsScreen', () {
    testWidgets('トグル ON で既定の型・容量で保存される', (tester) async {
      final container =
          await pumpScreen(tester, const ApplianceSettingsScreen());

      // ホットクックのトグルを ON にする。
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      final settings =
          await container.read(settingsRepositoryProvider).get();
      expect(settings.appliances.length, 1);
      expect(settings.appliances.first.type, ApplianceType.hotcook);
      expect(settings.appliances.first.series, 'KN-HW型');
      expect(settings.appliances.first.capacity, '1.0L');

      await unmountApp(tester);
    });

    testWidgets('容量チップの選択が保存される', (tester) async {
      final container =
          await pumpScreen(tester, const ApplianceSettingsScreen());

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('2.4L'));
      await tester.pumpAndSettle();

      final settings =
          await container.read(settingsRepositoryProvider).get();
      expect(settings.appliances.first.capacity, '2.4L');

      await unmountApp(tester);
    });

    testWidgets('トグル OFF で家電が削除される', (tester) async {
      final container =
          await pumpScreen(tester, const ApplianceSettingsScreen());
      await container.read(settingsRepositoryProvider).setAppliances(const [
        Appliance(type: ApplianceType.healsio, series: 'AX-XA型', capacity: '26L'),
      ]);
      await tester.pumpAndSettle();

      // ヘルシオ（2番目のカード）のトグルを OFF にする。
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();

      final settings =
          await container.read(settingsRepositoryProvider).get();
      expect(settings.appliances, isEmpty);

      await unmountApp(tester);
    });
  });
}
