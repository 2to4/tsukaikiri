import '../../features/inventory/domain/ingredient_category.dart';

/// 日持ち目安（最小手書き版）。
///
/// 設計メモの「最小手書きから」に従い、まずはカテゴリ別のフォールバック日数のみ。
/// 食材名単位の個別ルール・保存状態（冷蔵/冷凍/常温）・USDA FoodKeeper の
/// 取り込みは後フェーズで本格化する。値はすべて「目安」であり手動修正前提。
///
/// 後で JSON 同梱データに差し替えやすいよう、参照箇所は [defaultExpiryFrom] に集約する。
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
