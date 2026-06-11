import '../../features/inventory/domain/ingredient_category.dart';
import 'shelf_life_table.dart';

/// カテゴリ別のフォールバック日数（食材名でヒットしなかった場合に使う）。
///
/// 食材名単位の目安は USDA FoodKeeper 由来 + 和食材補完の [ShelfLifeTable]
/// （assets/shelf_life/shelf_life_rules.json、ビルド時に generate.dart で生成）が
/// 担う。ここはテーブルにヒットしないときの最終フォールバック。
/// 値はすべて「目安」であり手動修正前提。
const Map<IngredientCategory, int> categoryShelfLifeDays = {
  IngredientCategory.meat: 3,
  IngredientCategory.fish: 2,
  IngredientCategory.vegetable: 5,
  IngredientCategory.fruit: 7,
  IngredientCategory.dairy: 7,
  IngredientCategory.egg: 14,
  IngredientCategory.grain: 30,
  IngredientCategory.seasoning: 180,
  IngredientCategory.frozen: 90,
  IngredientCategory.beverage: 14,
  IngredientCategory.staple: 180,
  // other は目安を持たない（自動セットしない）
};

/// 登録日 [from] とカテゴリから賞味期限の初期値を求める。
/// 目安が無いカテゴリ（other 等）は null（＝期限なしのまま）。
DateTime? defaultExpiryFrom(IngredientCategory category, DateTime from) {
  final days = categoryShelfLifeDays[category];
  if (days == null) return null;
  return DateTime(from.year, from.month, from.day).add(Duration(days: days));
}

/// 食材名 [name]（とカテゴリ）から賞味期限の初期値を求める。
///
/// まず [table]（食材名単位の FoodKeeper + 和食材データ）を引き、ヒットすれば
/// その日数を使う。ミスしたら [defaultExpiryFrom]（カテゴリ別フォールバック）。
/// どちらも目安が無ければ null（＝期限なしのまま）。
DateTime? expiryFromName(
  ShelfLifeTable table,
  String name,
  IngredientCategory? category,
  DateTime from,
) {
  final base = DateTime(from.year, from.month, from.day);
  final days = table.daysFor(name, category: category);
  if (days != null) return base.add(Duration(days: days));
  if (category == null) return null;
  return defaultExpiryFrom(category, from);
}
