// shopping_desktop_view_test.dart
// M5 買い物リスト 2ペインビューの widget テスト。
// CLAUDE.md の規約に従い、インメモリ DB・1280×800・unmountApp パターン必須。
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
import 'package:tsukaikiri/features/shopping/presentation/shopping_desktop_view.dart';
import 'package:tsukaikiri/features/shopping/service/shopping_list_service.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

import 'fakes/fake_recipe_provider.dart';

// ──────────────────────────────────────────────────────────────
// フェイク ShoppingListService
// ──────────────────────────────────────────────────────────────

/// インメモリの ShoppingListService フェイク。
/// テスト毎に addItems の呼び出し履歴と結果を設定できる。
class FakeShoppingListService implements ShoppingListService {
  FakeShoppingListService({
    this.lists = const [],
    this.addItemsResult,
    this.failWithException = false,
    this.getListsFail = false,
  });

  /// getLists が返すリスト一覧。
  final List<ShoppingList> lists;

  /// addItems が返す件数。null のとき items.length を返す。
  final int? addItemsResult;

  /// true のとき addItems が例外を投げる。
  final bool failWithException;

  /// true のとき getLists が例外を投げる。
  final bool getListsFail;

  /// addItems に渡されたアイテムの累積記録。
  final List<ShoppingListItem> addedItems = [];

  /// addItems が呼ばれた listId。
  final List<String> addedToListId = [];

  @override
  Future<List<ShoppingList>> getLists() async {
    if (getListsFail) throw Exception('platform channel failure');
    return lists;
  }

  @override
  Future<ShoppingList> createList(String name) async {
    final newList = ShoppingList(id: 'new-$name', name: name);
    return newList;
  }

  @override
  Future<int> addItems(String listId, List<ShoppingListItem> items) async {
    if (failWithException) throw Exception('addItems failure');
    addedItems.addAll(items);
    addedToListId.add(listId);
    return addItemsResult ?? items.length;
  }
}

// ──────────────────────────────────────────────────────────────
// テストヘルパー
// ──────────────────────────────────────────────────────────────

/// 在庫食材を 1 件登録するヘルパー。
Future<void> seedIngredient(
  InventoryRepository repo, {
  required String name,
  double quantity = 1.0,
}) async {
  await repo.save(Ingredient(
    id: name,
    name: name,
    normalizedName: name,
    category: IngredientCategory.vegetable,
    quantity: quantity,
    unit: '個',
    updatedAt: DateTime.now(),
  ));
}

/// 決定済み献立を設定するヘルパー。mealsForShoppingProvider に乗せる。
SuggestedRecipe makeRecipe({
  String title = '鶏むね肉と野菜炒め',
  List<RecipeIngredient> ingredients = const [
    RecipeIngredient(name: '鶏むね肉', amount: '1枚'),
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

/// テスト環境向けウィジェットツリーをビルドし pump する。
/// [mealsForShopping] に献立を渡すと mealsForShoppingProvider に乗る。
Future<void> pumpView(
  WidgetTester tester, {
  required AppDatabase db,
  required FakeShoppingListService fakeShopping,
  FakeRecipeProvider? fakeRecipe,
  List<SuggestedRecipe> mealsForShopping = const [],
}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final recipe = fakeRecipe ?? FakeRecipeProvider();

  // pumpWidget はコールバック登録だけ行い、フレームを確定させない（pump を呼ばない）。
  // これにより initState が走り addPostFrameCallback が登録される。
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
        home: Scaffold(body: ShoppingDesktopView()),
      ),
    ),
  );

  // pumpWidget によってウィジェットが mount された時点で ProviderScope が存在する。
  // build の外（pump の前）なので Provider の変更が許可される。
  if (mealsForShopping.isNotEmpty) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShoppingDesktopView)),
    );
    container.read(mealsForShoppingProvider.notifier).set(mealsForShopping);
  }

  // ここで初めて pump を呼ぶと addPostFrameCallback（→ initialize()）が実行される。
  await tester.pump(); // postFrameCallback を実行 → initialize() 開始
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// drift stream 購読解除の Timer(0) を消化するためアンマウントする。
/// CLAUDE.md 規約: 各テスト末尾で必ず呼ぶ。
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
  // ① 対象なし状態: 案内テキストと「献立提案へ」ボタンが出る
  // ═══════════════════════════════════════════════════════
  testWidgets('① 対象なし: 案内テキストと「献立提案へ」ボタンを表示する',
      (tester) async {
    // 献立を設定しない → noTarget 状態
    final fakeShopping = FakeShoppingListService();
    await pumpView(tester, db: db, fakeShopping: fakeShopping);

    // 「献立を決めると不足食材がここに出ます」案内
    expect(find.textContaining('献立を決めると'), findsOneWidget);
    // 「献立提案へ」ボタン
    expect(find.text('献立提案へ'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ② 決定済み献立から不足食材一覧が出る（在庫にある食材は出ない）
  // ═══════════════════════════════════════════════════════
  testWidgets('② 不足食材一覧: 在庫にある材料は除外される', (tester) async {
    // 鶏むね肉は在庫あり、玉ねぎ・にんじんは不足。
    await seedIngredient(repo, name: '鶏むね肉');

    final recipe = makeRecipe();
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
    );
    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [recipe],
    );

    // 不足食材ヘッダーが出る（「不足食材 N品」）
    expect(find.textContaining('不足食材'), findsOneWidget);
    // 在庫にない玉ねぎ・にんじんは表示される
    expect(find.text('玉ねぎ'), findsOneWidget);
    expect(find.text('にんじん'), findsOneWidget);
    // 在庫にある鶏むね肉は出ない
    expect(find.text('鶏むね肉'), findsNothing);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ チェック解除で追加対象から外れる
  // ═══════════════════════════════════════════════════════
  testWidgets('③ チェック解除: opacity が下がり「すべて解除」に変わる',
      (tester) async {
    await seedIngredient(repo, name: '鶏むね肉'); // 在庫あり（除外される）
    final recipe = makeRecipe();
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
    );

    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [recipe],
    );

    // すべて選択状態のはず → ボタンは「すべて解除」
    expect(find.text('すべて解除'), findsOneWidget);

    // 玉ねぎのチェックボックスをタップして解除する。
    // Checkbox ウィジェットを特定して tap する。
    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsWidgets);
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();

    // 一部が解除されたら「すべて選択」に変わる。
    expect(find.text('すべて選択'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ 追加実行 → フェイクに記録されて完了表示
  // ═══════════════════════════════════════════════════════
  testWidgets('④ 追加実行: フェイクに記録され完了画面が出る', (tester) async {
    // 全食材が不足
    final recipe = makeRecipe(
      ingredients: const [
        RecipeIngredient(name: '玉ねぎ', amount: '1個'),
      ],
    );
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
      addItemsResult: 1,
    );

    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [recipe],
    );

    // リストが読み込まれてラジオ行が表示されるまで待つ。
    await tester.pump(const Duration(milliseconds: 200));

    // 「買い物」ラジオ行をタップしてリストを選択する。
    final listTile = find.text('買い物');
    expect(listTile, findsOneWidget);
    await tester.tap(listTile);
    await tester.pumpAndSettle();

    // 追加ボタンをタップする。
    final addBtn = find.textContaining('「買い物」に追加');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);

    // 非同期の addItems 完了を待つ。
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // フェイクに記録されていることを確認。
    expect(fakeShopping.addedItems, isNotEmpty);
    expect(fakeShopping.addedItems.first.title, '玉ねぎ');

    // 完了画面が出る。
    expect(find.textContaining('品を追加しました'), findsOneWidget);
    expect(find.text('リマインダーを開く'), findsOneWidget);
    expect(find.text('在庫に戻る'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤ addItems 失敗 → エラーメッセージが出る
  // ═══════════════════════════════════════════════════════
  testWidgets('⑤ addItems 失敗: エラーメッセージと再試行ボタンが出る',
      (tester) async {
    final recipe = makeRecipe(
      ingredients: const [
        RecipeIngredient(name: '玉ねぎ', amount: '1個'),
      ],
    );
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
      failWithException: true,
    );

    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [recipe],
    );

    // リストが読み込まれるまで待つ。
    await tester.pump(const Duration(milliseconds: 200));

    // リストを選択。
    await tester.tap(find.text('買い物'));
    await tester.pumpAndSettle();

    // 追加ボタンをタップ。
    await tester.tap(find.textContaining('「買い物」に追加'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // エラー状態: Wi-Fi 案内文と再試行ボタン。
    expect(find.textContaining('Wi-Fi'), findsOneWidget);
    expect(find.text('再試行'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑥ 数量ステッパーで増減できる
  // ═══════════════════════════════════════════════════════
  testWidgets('⑥ 数量ステッパー: ＋で増加、－で減少し最小1を下回らない',
      (tester) async {
    final recipe = makeRecipe(
      ingredients: const [
        RecipeIngredient(name: '玉ねぎ', amount: '1個'),
      ],
    );
    final fakeShopping = FakeShoppingListService(
      lists: const [ShoppingList(id: 'list-1', name: '買い物')],
    );

    await pumpView(
      tester,
      db: db,
      fakeShopping: fakeShopping,
      mealsForShopping: [recipe],
    );

    // 初期個数: 1個
    expect(find.text('1個'), findsOneWidget);

    // ＋ボタン（add アイコン）をタップ → 2個
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('2個'), findsOneWidget);

    // もう一度＋ → 3個
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('3個'), findsOneWidget);

    // － ボタン → 2個
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pumpAndSettle();
    expect(find.text('2個'), findsOneWidget);

    // 2 回 － → 1個（最小値）
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pumpAndSettle();
    // 最小 1 を下回らない
    expect(find.text('1個'), findsOneWidget);
    expect(find.text('0個'), findsNothing);

    await unmountApp(tester);
  });
}
