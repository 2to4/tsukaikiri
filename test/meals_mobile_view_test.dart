// meals_mobile_view_test.dart
// 献立提案 モバイル（狭い幅）版の widget テスト。
// CLAUDE.md の規約に従い、インメモリ DB・狭い幅・unmountApp パターン必須。

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/core/providers.dart';
import 'package:tsukaikiri/features/inventory/data/inventory_repository.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/recipe/domain/suggested_recipe.dart';
import 'package:tsukaikiri/features/recipe/presentation/meals_mobile_view.dart';
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
    // スマホ幅（狭い）を再現する。
    tester.view.physicalSize = const Size(390, 844);
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
          home: MealsMobileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 生成中はパルスアニメーションが回り続け pumpAndSettle が収束しないため、
  /// 提案ボタン押下後は固定回数だけ pump して結果状態まで進める。
  Future<void> tapSuggestAndWait(WidgetTester tester) async {
    await tester.tap(find.text('在庫から提案する'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// drift stream 購読解除の Timer(0) を消化するためアンマウントする。
  Future<void> unmountApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  // 鶏むね肉は在庫あり、玉ねぎは不足。
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
  // ① 提案前 → 提案実行 → 結果カード表示
  // ═══════════════════════════════════════════════════════
  testWidgets('提案前は提案ボタンと条件チップを表示し、提案で結果カードが出る',
      (tester) async {
    await seedPlenty();
    final fake = FakeRecipeProvider(suggestResult: [sampleRecipe()]);
    await pumpView(tester, fake);

    // 提案前
    expect(find.text('在庫から提案する'), findsOneWidget);
    expect(find.text('おまかせ'), findsWidgets);
    expect(find.text('主菜のみ'), findsWidgets);

    await tapSuggestAndWait(tester);

    // 結果カード（タイトルが見える。デフォルトは折りたたみ）
    expect(find.text('鶏むね肉とほうれん草の炒め'), findsOneWidget);
    // 折りたたみ中は手順は出ない
    expect(find.text('鶏むね肉を切る。'), findsNothing);

    // カードを展開すると材料・手順が出る
    await tester.tap(find.text('鶏むね肉とほうれん草の炒め'));
    await tester.pumpAndSettle();
    expect(find.text('材料'), findsOneWidget);
    expect(find.text('手順'), findsOneWidget);
    expect(find.text('鶏むね肉を切る。'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ② エラー表示
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
    expect(find.text('在庫にもどる'), findsOneWidget);

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ③ 「これ作る」トグル → 買い物リストへ CTA 出現
  // ═══════════════════════════════════════════════════════
  testWidgets('「これ作る」を押すと決定済みになり買い物リスト CTA が出る',
      (tester) async {
    await seedPlenty();
    final fake = FakeRecipeProvider(suggestResult: [sampleRecipe()]);
    await pumpView(tester, fake);

    await tapSuggestAndWait(tester);

    // 決定前は CTA なし
    expect(find.textContaining('買い物リストへ'), findsNothing);

    // カードを展開して「これ作る」トグル
    await tester.tap(find.text('鶏むね肉とほうれん草の炒め'));
    await tester.pumpAndSettle();
    expect(find.text('献立に決める'), findsOneWidget);

    await tester.tap(find.text('献立に決める'));
    await tester.pumpAndSettle();

    // 決定済みに変わり、買い物リスト CTA が出る
    expect(find.text('決定済み'), findsOneWidget);
    expect(find.textContaining('買い物リストへ'), findsOneWidget);

    // CTA を押すと mealsForShopping に決定分が set される
    await tester.tap(find.textContaining('買い物リストへ'));
    await tester.pump();

    await unmountApp(tester);
  });

  // ═══════════════════════════════════════════════════════
  // ④ 在庫わずか（≤3件）バナー
  // ═══════════════════════════════════════════════════════
  testWidgets('在庫が少ないと在庫わずかバナーを表示する', (tester) async {
    await seed('にんじん'); // 1件のみ
    final fake = FakeRecipeProvider(suggestResult: [sampleRecipe()]);
    await pumpView(tester, fake);

    await tapSuggestAndWait(tester);

    expect(find.textContaining('買い足し前提'), findsOneWidget);
    expect(fake.suggestCalls.single.allowNewIngredients, isTrue);

    await unmountApp(tester);
  });
}
