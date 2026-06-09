import 'package:flutter/material.dart';

import 'ingredient_category.dart';

/// カテゴリごとの見た目（タイル色＋代表絵文字）。
///
/// Claude Design の `CATS`（肉/魚/野菜/乳製品/調味料/常備品）の色を基準に、
/// 12 カテゴリ全てへ拡張したもの。データモデルに絵文字を持たないため、
/// タイルにはカテゴリ代表の絵文字を表示する。
class CategoryStyle {
  const CategoryStyle(this.tile, this.emoji);
  final Color tile;
  final String emoji;
}

const Map<IngredientCategory, CategoryStyle> _styles = {
  IngredientCategory.meat: CategoryStyle(Color(0xFFF3E1DB), '🍖'),
  IngredientCategory.fish: CategoryStyle(Color(0xFFE1EAF1), '🐟'),
  IngredientCategory.vegetable: CategoryStyle(Color(0xFFE6F0E1), '🥬'),
  IngredientCategory.fruit: CategoryStyle(Color(0xFFF6E2C8), '🍎'),
  IngredientCategory.dairy: CategoryStyle(Color(0xFFF4ECD9), '🥛'),
  IngredientCategory.egg: CategoryStyle(Color(0xFFF8EFD2), '🥚'),
  IngredientCategory.grain: CategoryStyle(Color(0xFFECE4CF), '🍚'),
  IngredientCategory.seasoning: CategoryStyle(Color(0xFFEFE6D5), '🧂'),
  IngredientCategory.frozen: CategoryStyle(Color(0xFFE1EDF1), '🧊'),
  IngredientCategory.beverage: CategoryStyle(Color(0xFFE2ECE8), '🧃'),
  IngredientCategory.staple: CategoryStyle(Color(0xFFEAE7DF), '🥫'),
  IngredientCategory.other: CategoryStyle(Color(0xFFECEAE3), '🍽️'),
};

extension CategoryStyleX on IngredientCategory {
  CategoryStyle get style => _styles[this]!;
}
