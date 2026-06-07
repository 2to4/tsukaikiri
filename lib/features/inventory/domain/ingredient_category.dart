import '../../../l10n/app_localizations.dart';

/// 在庫食材のカテゴリ（12種・宣言順が表示順）。
///
/// 名寄せキー（normalizedName）と同様、列挙子名は言語非依存の固定キーとして
/// DB に保存する（Drift の textEnum）。UI 表示は [label] でローカライズする。
enum IngredientCategory {
  meat,
  fish,
  vegetable,
  fruit,
  dairy,
  egg,
  grain,
  seasoning,
  frozen,
  beverage,
  staple,
  other;

  String label(AppLocalizations l10n) => switch (this) {
        IngredientCategory.meat => l10n.categoryMeat,
        IngredientCategory.fish => l10n.categoryFish,
        IngredientCategory.vegetable => l10n.categoryVegetable,
        IngredientCategory.fruit => l10n.categoryFruit,
        IngredientCategory.dairy => l10n.categoryDairy,
        IngredientCategory.egg => l10n.categoryEgg,
        IngredientCategory.grain => l10n.categoryGrain,
        IngredientCategory.seasoning => l10n.categorySeasoning,
        IngredientCategory.frozen => l10n.categoryFrozen,
        IngredientCategory.beverage => l10n.categoryBeverage,
        IngredientCategory.staple => l10n.categoryStaple,
        IngredientCategory.other => l10n.categoryOther,
      };
}
