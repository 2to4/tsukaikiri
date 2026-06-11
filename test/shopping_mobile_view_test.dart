// shopping_mobile_view_test.dart
// M5 買い物リスト モバイル（狭い幅）版の widget テスト。
// CLAUDE.md の規約に従い、インメモリ DB・狭い幅・unmountApp パターン必須。
// 在庫の読み出しはコントローラの一発クエリ経路（getInventory）を経由するため
// StreamProvider の .first を使わずテストがハングしない。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/recipe/domain/suggested_recipe.dart';
import 'package:tsukaikiri/features/recipe/presentation/meal_suggestion_controller.dart';
import 'package:tsukaikiri/features/shopping/domain/shopping_list.dart';
import 'package:tsukaikiri/features/shopping/presentation/shopping_mobile_view.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

import 'fakes/fake_recipe_provider.dart';
import 'shopping_desktop_view_test.dart' show FakeShoppingListService;

// ──────────────────────────────────────────────────────────────
// テストヘルパー
// ──────────────────────────────────────────────────────────────

Future<void> seedIngredient(
  InventoryRepository repo, {
  required String name,
}) async {
  await repo.save(Ingredient(
    id: name,
    name: name,
    normalizedName: name,
    category: IngredientCategory.vegetable,
    quantity: 1.0,
    unit: '個',
    updatedAt: DateTime.now(),
  ));
}

SuggestedRecipe makeRecipe({
  String title = '鶏むね肉と野菜炒め',
  List<RecipeIngredient> ingredients = const [
    RecipeIngredient(name: '玉ねぎ', amount: '1個'),
    RecipeIngredient(name: 'にんじん', amount: '1本'),
  ],
}) =>
    SuggestedRecipe(
      title: title,
      ingredients: ingredients,
      appliance: null,
      cookMinutes: 20,
      steps: const ['切る', '炒める'],
      usesExpiringSoon: false,
    );

/// 狭い幅（スマホ）でツリーをビルドし、mealsForShopping を載せて
/// initialize()（postFrameCallback）を実行する。
Future<void> pumpView(
  WidgetTester tester, {
  required AppDatabase db,
  required FakeShoppingListService fakeShopping,
  FakeRecipeProvider? fakeRecipe,
  List<SuggestedRecipe> mealsForShopping = const [],
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final recipe = fakeRecipe ?? FakeRecipeProvider();

  // pumpWidget はコールバック登録だけ行い、フレームは確定させない。
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        shoppingListServiceProvider.overrideWithValue(fakeShopping),
        recipeProviderProvider.overrideWith((ref) async => recipe),
      ],
      child: const MaterialApp(
        locale: Locale('ja'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ShoppingMobileScreen(),
      ),
    ),
  );

  // build の外（pump の前）で Provider を更新する。
  if (mealsForShopping.isNotEmpty) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShoppingMobileScreen)),
    );
    container.read(mealsForShoppingProvider.notifier).set(mealsForShopping);
  }

  // ここで初めて pump → postFrameCallback（initialize）が走る。
  await tester.pump();
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// drift stream 購読解除の Timer(0) を消化するためアンマウントする。
Future<void> unmountApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

// ──────────────────────────────────────────────────────────────
// テスト本体
// ──────────────────────────────────────────────────────────────

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  // ═══════════════════════════════════════════════════════
  // ① 不足食材一覧 → チェック解除でトグルボタンが変わる
  // ═══════════════════════════════════════════════════════
  testWidgets('① 不足食材一覧を表示し、チェック解除で「すべて選択」に変わる',
      (tester) async {
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
    );
    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [makeRecipe()],
    );

    // 不足食材タイトル + サマリー
    expect(find.text('買い物リスト'), findsOneWidget);
    expect(find.textContaining('不足'), findsWidgets);
    // 不足食材（在庫なし）が並ぶ
    expect(find.text('玉ねぎ'), findsOneWidget);
    expect(find.text('にんじん'), findsOneWidget);

    // 全選択状態 → 「すべて解除」
    expect(find.text('すべて解除'), findsOneWidget);

    // 1件チェックを外すと「すべて選択」に変わる。
    await tester.tap(find.text('玉ねぎ'));
    await tester.pumpAndSettle();
    // 名前タップでは外れない。チェックボタンをタップする必要がある。
    // _Check は GestureDetector。最初のアイテムのチェックを外す。
    await tester.tap(find.byIcon(Icons.check).first);
    await tester.pumpAndSettle();
    expect(find.text('すべて選択'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ② 在庫にある食材は一覧から除外される
  // ═══════════════════════════════════════════════════════
  testWidgets('② 在庫にある材料は不足一覧から除外される', (tester) async {
    await seedIngredient(repo, name: '玉ねぎ'); // 在庫あり
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
    );
    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [makeRecipe()],
    );

    expect(find.text('玉ねぎ'), findsNothing);
    expect(find.text('にんじん'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ リスト選択 → 追加実行 → 完了表示
  // ═══════════════════════════════════════════════════════
  testWidgets('③ リスト選択→追加で完了画面が出てフェイクに記録される',
      (tester) async {
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
      addItemsResult: 1,
    );
    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [
        makeRecipe(ingredients: const [RecipeIngredient(name: '玉ねぎ', amount: '1個')]),
      ],
    );

    // 追加先カードを開く（「変更」行をタップ）。
    await tester.tap(find.text('変更'));
    await tester.pump(const Duration(milliseconds: 200));

    // 「買い物」リストを選択する。
    expect(find.text('買い物'), findsOneWidget);
    await tester.tap(find.text('買い物'));
    await tester.pumpAndSettle();

    // 追加ボタン（「買い物」に追加）をタップ。
    final addBtn = find.textContaining('「買い物」に追加');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // フェイクに記録される。
    expect(fakeShopping.addedItems, isNotEmpty);
    expect(fakeShopping.addedItems.first.title, '玉ねぎ');

    // 完了画面。
    expect(find.textContaining('品を追加しました'), findsOneWidget);
    expect(find.text('在庫に戻る'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ addItems 失敗 → エラー表示 + リトライ導線
  // ═══════════════════════════════════════════════════════
  testWidgets('④ 追加失敗でエラー表示と「もう一度試す」導線が出る',
      (tester) async {
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
      failWithException: true,
    );
    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [
        makeRecipe(ingredients: const [RecipeIngredient(name: '玉ねぎ', amount: '1個')]),
      ],
    );

    await tester.tap(find.text('変更'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('買い物'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('「買い物」に追加'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // エラー画面: Wi-Fi 文言 + もう一度試す + 保持メッセージ。
    expect(find.textContaining('Wi-Fi'), findsOneWidget);
    expect(find.text('もう一度試す'), findsOneWidget);
    expect(find.textContaining('保持されています'), findsOneWidget);

    // 「もう一度試す」で一覧（listing）に戻る。
    await tester.tap(find.text('もう一度試す'));
    await tester.pumpAndSettle();
    expect(find.text('買い物リスト'), findsOneWidget);
    expect(find.text('玉ねぎ'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤ 数量ステッパー（最小1）
  // ═══════════════════════════════════════════════════════
  testWidgets('⑤ 数量ステッパーは＋で増え、最小1を下回らない', (tester) async {
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
    );
    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [
        makeRecipe(ingredients: const [RecipeIngredient(name: '玉ねぎ', amount: '1個')]),
      ],
    );

    expect(find.text('1個'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('2個'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pumpAndSettle();
    expect(find.text('1個'), findsOneWidget);
    expect(find.text('0個'), findsNothing);

    await unmountApp(tester);
  });
}
