// ingredient_detail_shopping_test.dart
// 在庫詳細の「買い物リストに追加」の widget テスト。
// CLAUDE.md の規約に従い、インメモリ DB + unmountApp + SnackBar タイマー消化。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/inventory/presentation/widgets/ingredient_detail_view.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

import 'shopping_desktop_view_test.dart' show FakeShoppingListService;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<void> seedIngredient(ProviderContainer container) async {
    await container.read(inventoryRepositoryProvider).save(Ingredient(
          id: 'tofu-1',
          name: '豆腐',
          normalizedName: 'tofu',
          category: IngredientCategory.other,
          quantity: 1,
          unit: '個',
          expiryDate: null,
          updatedAt: DateTime.now(),
        ));
  }

  Future<ProviderContainer> pumpView(
    WidgetTester tester,
    FakeShoppingListService service,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          shoppingListServiceProvider.overrideWithValue(service),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: IngredientDetailView(ingredientId: 'tofu-1'),
          ),
        ),
      ),
    );
    final container = ProviderScope.containerOf(
        tester.element(find.byType(IngredientDetailView)));
    await seedIngredient(container);
    await tester.pumpAndSettle();
    return container;
  }

  /// SnackBar のタイマーを消化してからアンマウントする。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('リスト設定済み: タップでサービスに1件追加され成功トーストが出る', (tester) async {
    final service = FakeShoppingListService();
    final container = await pumpView(tester, service);

    // 買い物リストを設定しておく。
    await container
        .read(settingsRepositoryProvider)
        .setShoppingList('list-1', '買い物');
    await tester.pump();

    await tester.tap(find.text('買い物リストに追加'));
    await tester.pumpAndSettle();

    expect(service.addedToListId, ['list-1']);
    expect(service.addedItems.single.title, '豆腐');
    expect(find.text('買い物リストに追加しました'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('リスト未設定: 設定への誘導メッセージが出てサービスは呼ばれない', (tester) async {
    final service = FakeShoppingListService();
    await pumpView(tester, service);

    await tester.tap(find.text('買い物リストに追加'));
    await tester.pumpAndSettle();

    expect(service.addedItems, isEmpty);
    expect(find.text('設定で買い物リストを選択してください'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('追加失敗: オフライン文言が出る', (tester) async {
    final service = FakeShoppingListService(failWithException: true);
    final container = await pumpView(tester, service);

    await container
        .read(settingsRepositoryProvider)
        .setShoppingList('list-1', '買い物');
    await tester.pump();

    await tester.tap(find.text('買い物リストに追加'));
    await tester.pumpAndSettle();

    expect(find.text('電波の良い場所か Wi-Fi に接続してください。'), findsOneWidget);

    await unmountApp(tester);
  });
}
