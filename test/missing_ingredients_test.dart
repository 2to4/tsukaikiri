import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/recipe/domain/suggested_recipe.dart';
import 'package:tsukaikiri/features/shopping/service/missing_ingredients_service.dart';

import 'fakes/fake_recipe_provider.dart';

Ingredient stock(String name,
        {double quantity = 1, String? normalizedName}) =>
    Ingredient(
      id: name,
      name: name,
      normalizedName: normalizedName ?? name,
      category: IngredientCategory.vegetable,
      quantity: quantity,
      unit: 'piece',
      expiryDate: null,
      updatedAt: DateTime(2026, 6, 10),
    );

SuggestedRecipe recipe(String title, Map<String, String> ingredients) =>
    SuggestedRecipe(
      title: title,
      ingredients: [
        for (final e in ingredients.entries)
          RecipeIngredient(name: e.key, amount: e.value),
      ],
      steps: const ['作る'],
    );

void main() {
  group('findMissingIngredients', () {
    test('名前一致（trim・大文字小文字無視）で在庫ありと判定する', () {
      final missing = findMissingIngredients(
        recipes: [
          recipe('サラダ', {'Tomato ': '1個', 'レタス': '半玉'})
        ],
        inventory: [stock('tomato')],
      );
      expect(missing.map((m) => m.name), ['レタス']);
    });

    test('数量 0 の在庫は不足扱いになる', () {
      final missing = findMissingIngredients(
        recipes: [
          recipe('卵焼き', {'卵': '3個'})
        ],
        inventory: [stock('卵', quantity: 0)],
      );
      expect(missing.map((m) => m.name), ['卵']);
    });

    test('名寄せキー経由で表記ゆれを在庫ありと判定する', () {
      final missing = findMissingIngredients(
        recipes: [
          recipe('チキンソテー', {'鶏むね肉': '1枚', '塩': '少々'})
        ],
        inventory: [stock('鶏胸肉', normalizedName: 'chicken_breast')],
        normalizedNames: const {'鶏むね肉': 'chicken_breast'},
      );
      expect(missing.map((m) => m.name), ['塩']);
    });

    test('複数献立の同一材料は集約し由来と分量を保持する', () {
      final missing = findMissingIngredients(
        recipes: [
          recipe('肉じゃが', {'じゃがいも': '2個'}),
          recipe('カレー', {'じゃがいも': '3個', '人参': '1本'}),
        ],
        inventory: const [],
      );
      expect(missing, hasLength(2));
      final potato = missing.firstWhere((m) => m.name == 'じゃがいも');
      expect(potato.sources.map((s) => '${s.recipeTitle}:${s.amount}'),
          ['肉じゃが:2個', 'カレー:3個']);
    });

    test('名寄せキーが同じ別表記の材料は同一視する', () {
      final missing = findMissingIngredients(
        recipes: [
          recipe('A', {'鶏むね': '1枚'}),
          recipe('B', {'鶏胸肉': '2枚'}),
        ],
        inventory: const [],
        normalizedNames: const {
          '鶏むね': 'chicken_breast',
          '鶏胸肉': 'chicken_breast',
        },
      );
      expect(missing, hasLength(1));
      expect(missing.single.name, '鶏むね');
      expect(missing.single.sources, hasLength(2));
    });

    test('toShoppingListItem はタイトル=名前・notes=由来と分量にする', () {
      final missing = findMissingIngredients(
        recipes: [
          recipe('肉じゃが', {'じゃがいも': '2個'}),
          recipe('カレー', {'じゃがいも': '3個'}),
        ],
        inventory: const [],
      );
      final item = missing.single.toShoppingListItem();
      expect(item.title, 'じゃがいも');
      expect(item.notes, '肉じゃが: 2個 / カレー: 3個');
    });
  });

  group('MissingIngredientsService', () {
    test('材料名を重複なく normalize に渡し結果を突き合わせに使う', () async {
      final provider = FakeRecipeProvider(
        normalizedKeys: const {'鶏むね肉': 'chicken_breast'},
      );
      final service = MissingIngredientsService(provider);
      final missing = await service.find(
        recipes: [
          recipe('A', {'鶏むね肉': '1枚'}),
          recipe('B', {'鶏むね肉': '1枚', '塩': '少々'}),
        ],
        inventory: [stock('鶏胸肉', normalizedName: 'chicken_breast')],
      );
      expect(provider.normalizeCalls.single, ['鶏むね肉', '塩']);
      expect(missing.map((m) => m.name), ['塩']);
    });

    test('献立が空なら AI を呼ばない', () async {
      final provider = FakeRecipeProvider();
      final missing = await MissingIngredientsService(provider)
          .find(recipes: const [], inventory: const []);
      expect(missing, isEmpty);
      expect(provider.normalizeCalls, isEmpty);
    });
  });
}
