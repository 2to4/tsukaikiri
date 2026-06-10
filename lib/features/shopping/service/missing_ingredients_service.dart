import '../../../core/db/app_database.dart';
import '../../recipe/domain/suggested_recipe.dart';
import '../../recipe/service/recipe_provider.dart';
import '../domain/missing_ingredient.dart';

/// 献立の材料と在庫を突き合わせて不足材料を抽出する（純ロジック）。
///
/// 突き合わせ規則（確定）:
/// - 在庫扱いは数量 > 0 のもののみ（0 の行は「買う必要あり」とみなす）
/// - まず名前の一致（trim + 小文字化）、次に名寄せキーの一致で判定
/// - [normalizedNames] は材料名 → 正規化キーのマップ（AI の normalize 結果）。
///   空でも動作する（名前一致のみになる）
/// - 名寄せキーが同じ材料は同一視し、由来献立ごとの分量を [MissingIngredient.sources] に集約
List<MissingIngredient> findMissingIngredients({
  required List<SuggestedRecipe> recipes,
  required List<Ingredient> inventory,
  Map<String, String> normalizedNames = const {},
}) {
  String norm(String s) => s.trim().toLowerCase();

  final stocked = inventory.where((i) => i.quantity > 0).toList();
  final stockedNames = stocked.map((i) => norm(i.name)).toSet();
  final stockedKeys = stocked.map((i) => norm(i.normalizedName)).toSet();

  // 挿入順を保つことで「最初に出現した献立での表記」が表示名になる。
  final result = <String, MissingIngredient>{};
  for (final recipe in recipes) {
    for (final ingredient in recipe.ingredients) {
      final key = normalizedNames[ingredient.name];
      final inStock = stockedNames.contains(norm(ingredient.name)) ||
          (key != null && stockedKeys.contains(norm(key)));
      if (inStock) continue;

      final dedupeKey = key != null ? norm(key) : norm(ingredient.name);
      final source = MissingIngredientSource(
        recipeTitle: recipe.title,
        amount: ingredient.amount,
      );
      final existing = result[dedupeKey];
      result[dedupeKey] = existing == null
          ? MissingIngredient(name: ingredient.name, sources: [source])
          : MissingIngredient(
              name: existing.name,
              sources: [...existing.sources, source],
            );
    }
  }
  return result.values.toList();
}

/// AI の名寄せを組み合わせた不足材料抽出サービス。
/// 「鶏むね肉（献立側）」と「鶏胸肉（在庫側）」のような表記ゆれを吸収する。
class MissingIngredientsService {
  MissingIngredientsService(this._provider);

  final RecipeProvider _provider;

  /// 通信失敗時は [RecipeProviderException] 等が伝播する
  /// （オフライン方針に従い UI 側でエラー表示して再試行を促す）。
  Future<List<MissingIngredient>> find({
    required List<SuggestedRecipe> recipes,
    required List<Ingredient> inventory,
  }) async {
    final names = {
      for (final recipe in recipes)
        for (final ingredient in recipe.ingredients) ingredient.name,
    }.toList();
    final normalizedNames =
        names.isEmpty ? const <String, String>{} : await _provider.normalize(names);
    return findMissingIngredients(
      recipes: recipes,
      inventory: inventory,
      normalizedNames: normalizedNames,
    );
  }
}
