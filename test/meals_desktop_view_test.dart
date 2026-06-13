// meals_desktop_view_test.dart
// M4 献立提案 2ペインビューの widget テスト。
// CLAUDE.md の規約に従い、インメモリ DB・1280×800・unmountApp パターン必須。

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
import 'package:tsukaikiri/features/recipe/presentation/meals_desktop_view.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_provider.dart';
import 'package:tsukaikiri/l10n/app_localizations.dart';

import 'fakes/fake_recipe_provider.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);
  });

  tearDown(() async => db.close());

  Future<void> seed(String name) async {
    await repo.save(Ingredient(
      id: name,
      name: name,
      normalizedName: name,
      category: IngredientCategory.vegetable,
      quantity: 1,
      unit: '個',
      updatedAt: DateTime.now(),
    ));
  }

  /// 在庫を 4 件投入して results（在庫わずかでない）状態を作れるようにする。
  Future<void> seedPlenty() async {
    await seed('鶏むね肉');
    await seed('ほうれん草');
    await seed('にんじん');
    await seed('卵');
  }

  Future<void> pumpView(
    WidgetTester tester,
    FakeRecipeProvider fake,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          recipeProviderProvider.overrideWith((ref) async => fake),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MealsDesktopView()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 生成中はパルスアニメーションが回り続け pumpAndSettle が収束しないため、
  /// 提案ボタン押下後は固定回数だけ pump して結果状態まで進める。
  Future<void> tapSuggestAndWait(WidgetTester tester) async {
    await tester.tap(find.text('在庫から提案する'));
    // 非同期の suggest() 完了（in-memory DB 読み込み + フェイク応答）を待つ。
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// drift stream 購読解除の Timer(0) を消化するためアンマウントする。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  // 共通: 鶏むね肉とほうれん草の献立。鶏むね肉は在庫あり、玉ねぎは不足。
  SuggestedRecipe sampleRecipe() => const SuggestedRecipe(
        title: '鶏むね肉とほうれん草の炒め',
        ingredients: [
          RecipeIngredient(name: '鶏むね肉', amount: '2枚'),
          RecipeIngredient(name: '玉ねぎ', amount: '1個'),
        ],
        appliance: null,
        cookMinutes: 15,
        steps: ['鶏むね肉を切る。', '炒める。'],
        usesExpiringSoon: true,
      );

  // ═══════════════════════════════════════════════════════
  // ① 提案前状態の表示
  // ═══════════════════════════════════════════════════════
  testWidgets('提案前は案内テキストと提案ボタンを表示する', (tester) async {
    await seedPlenty();
    await pumpView(tester, FakeRecipeProvider());

    expect(find.text('在庫から提案する'), findsOneWidget);
    expect(find.text('「在庫から提案する」をクリックしてください'), findsOneWidget);
    // 条件チップ
    expect(find.text('おまかせ'), findsOneWidget);
    expect(find.text('主菜のみ'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ①' AI 非対応端末（provider 解決不可）では案内を表示し提案を無効化
  // ═══════════════════════════════════════════════════════
  testWidgets('AI 非対応端末では提案を無効化し案内を表示する', (tester) async {
    await seedPlenty();
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // オンデバイス不可 + キー無し相当（解決が null）。
          recipeProviderProvider.overrideWith((ref) async => null),
        ],
        child: const MaterialApp(
          locale: Locale('ja'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MealsDesktopView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 案内が表示され、提案前の通常ヒントは出ない。
    expect(find.text('AI を利用できません'), findsOneWidget);
    expect(find.text('「在庫から提案する」をクリックしてください'), findsNothing);

    // 提案ボタンは無効（タップしても案内のまま＝生成に進まない）。
    await tester.tap(find.text('在庫から提案する'));
    await tester.pumpAndSettle();
    expect(find.text('AI を利用できません'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ② 提案実行 → 結果リスト → 行クリックで詳細
  // ═══════════════════════════════════════════════════════
  testWidgets('提案を実行すると結果が並び、行クリックで詳細が出る', (tester) async {
    await seedPlenty();
    final fake = FakeRecipeProvider(suggestResult: [sampleRecipe()]);
    await pumpView(tester, fake);

    await tapSuggestAndWait(tester);

    // 結果が並ぶ（リスト行 + 詳細ヘッダーで複数ヒット）
    expect(find.text('鶏むね肉とほうれん草の炒め'), findsWidgets);
    // 先頭が自動選択され詳細の「材料」「手順」が出る
    expect(find.text('材料'), findsOneWidget);
    expect(find.text('手順'), findsOneWidget);
    // 手順テキスト
    expect(find.text('鶏むね肉を切る。'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ 材料の在庫あり/不足の色分け根拠
  // ═══════════════════════════════════════════════════════
  testWidgets('在庫にある材料は greenSoft、不足は nearSoft で表示する', (tester) async {
    await seedPlenty(); // 鶏むね肉は在庫あり、玉ねぎは無し
    final fake = FakeRecipeProvider(suggestResult: [sampleRecipe()]);
    await pumpView(tester, fake);

    await tapSuggestAndWait(tester);

    // 材料チップの背景色を検証する。
    Color chipColor(String label) {
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(Container),
        ).first,
      );
      return (container.decoration as BoxDecoration).color!;
    }

    // 在庫あり = greenSoft
    expect(chipColor('鶏むね肉 2枚'), const Color(0xFFE8F3EC));
    // 不足 = nearSoft
    expect(chipColor('玉ねぎ 1個'), const Color(0xFFFBEBD8));

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ エラー時のメッセージと再試行
  // ═══════════════════════════════════════════════════════
  testWidgets('提案が失敗するとオフライン文言と再試行ボタンを表示する', (tester) async {
    await seedPlenty();
    final fake = FakeRecipeProvider(
      suggestError: const RecipeProviderException('gemini', 503, 'unavailable'),
    );
    await pumpView(tester, fake);

    await tapSuggestAndWait(tester);

    expect(find.textContaining('Wi-Fi'), findsOneWidget);
    expect(find.text('再試行'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑤ 「献立に決める」のトグル
  // ═══════════════════════════════════════════════════════
  testWidgets('「献立に決める」を押すとトグルし決定済み表示になる', (tester) async {
    await seedPlenty();
    final fake = FakeRecipeProvider(suggestResult: [sampleRecipe()]);
    await pumpView(tester, fake);

    await tapSuggestAndWait(tester);

    // 初期は「献立に決める」
    expect(find.text('献立に決める'), findsOneWidget);
    expect(find.text('決定済み'), findsNothing);

    await tester.tap(find.text('献立に決める'));
    await tester.pumpAndSettle();

    // 決定済みに変わる
    expect(find.text('決定済み'), findsOneWidget);
    expect(find.text('献立に決める'), findsNothing);

    // もう一度押すと解除される
    await tester.tap(find.text('決定済み'));
    await tester.pumpAndSettle();
    expect(find.text('献立に決める'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ⑥ 在庫わずか（≤3件）はバナーと新規食材許可
  // ═══════════════════════════════════════════════════════
  testWidgets('在庫が少ないと在庫わずかバナーを表示し制約に新規食材許可が乗る',
      (tester) async {
    await seed('にんじん'); // 1件のみ
    final fake = FakeRecipeProvider(suggestResult: [sampleRecipe()]);
    await pumpView(tester, fake);

    await tapSuggestAndWait(tester);

    expect(find.textContaining('買い足し前提'), findsOneWidget);
    // 制約に allowNewIngredients が乗っている
    expect(fake.suggestCalls.single.allowNewIngredients, isTrue);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // Phase3: focusIngredient バナー UI (detail recipe から)
  // ═══════════════════════════════════════════════════════
  testWidgets('focus 設定で起点食材バナーが表示されクリア可能 (desktop)', (tester) async {
    await seedPlenty();
    final fake = FakeRecipeProvider(suggestResult: [sampleRecipe()]);
    await pumpView(tester, fake);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MealsDesktopView)),
    );
    final focusIng = (await repo.getInventory()).first;
    container.read(mealSuggestionControllerProvider.notifier).suggestFromIngredient(focusIng);
    await tester.pumpAndSettle();

    // バナー ( _FocusIngredientBanner ) テキスト (名前はレシピタイトル等にもあるので banner 形式で特定)
    expect(find.textContaining('「${focusIng.name}」から提案中'), findsOneWidget);

    // クリアアイコンで消す
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.textContaining('から提案中'), findsNothing);

    await unmountApp(tester);
  });
}
