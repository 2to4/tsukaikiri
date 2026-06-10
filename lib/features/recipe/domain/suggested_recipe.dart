/// AI が提案した献立（一時オブジェクト。DB 保存は後フェーズ）。
class SuggestedRecipe {
  const SuggestedRecipe({
    required this.title,
    required this.ingredients,
    this.appliance,
    this.cookMode,
    this.cookMinutes,
    required this.steps,
    this.usesExpiringSoon = false,
  });

  factory SuggestedRecipe.fromJson(Map<String, dynamic> json) =>
      SuggestedRecipe(
        title: json['title'] as String,
        ingredients: (json['ingredients'] as List)
            .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
            .toList(),
        appliance: json['appliance'] as String?,
        cookMode: json['cookMode'] as String?,
        cookMinutes: (json['cookMinutes'] as num?)?.toInt(),
        steps: (json['steps'] as List).map((e) => e as String).toList(),
        usesExpiringSoon: json['usesExpiringSoon'] as bool? ?? false,
      );

  final String title;
  final List<RecipeIngredient> ingredients;

  /// 'hotcook' / 'healsio' / null（通常調理）
  final String? appliance;
  final String? cookMode;
  final int? cookMinutes;
  final List<String> steps;
  final bool usesExpiringSoon;
}

class RecipeIngredient {
  const RecipeIngredient({required this.name, required this.amount});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        name: json['name'] as String,
        amount: json['amount'] as String,
      );

  final String name;
  final String amount;
}
