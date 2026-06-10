import 'dart:typed_data';

import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/features/recipe/domain/ai_model.dart';
import 'package:tsukaikiri/features/recipe/domain/detected_ingredient.dart';
import 'package:tsukaikiri/features/recipe/domain/recipe_constraints.dart';
import 'package:tsukaikiri/features/recipe/domain/suggested_recipe.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_provider.dart';

/// normalize / suggestRecipes を差し替えられるテスト用 RecipeProvider。
class FakeRecipeProvider implements RecipeProvider {
  FakeRecipeProvider({
    this.normalizedKeys = const {},
    this.suggestResult = const [],
    this.suggestError,
  });

  /// normalize が返すマップ（渡された名前に含まれるものだけ返す）。
  final Map<String, String> normalizedKeys;

  /// suggestRecipes が返す献立リスト。
  final List<SuggestedRecipe> suggestResult;

  /// 非 null のとき suggestRecipes はこの例外を投げる。
  final RecipeProviderException? suggestError;

  /// normalize が呼ばれた際の引数履歴。
  final List<List<String>> normalizeCalls = [];

  /// suggestRecipes が呼ばれた際の制約履歴。
  final List<RecipeConstraints> suggestCalls = [];

  @override
  String get displayName => 'Fake';

  @override
  String get modelId => 'fake-model';

  @override
  bool get supportsVision => false;

  @override
  Future<Map<String, String>> normalize(List<String> names) async {
    normalizeCalls.add(names);
    return {
      for (final name in names)
        if (normalizedKeys.containsKey(name)) name: normalizedKeys[name]!,
    };
  }

  @override
  Future<List<AiModel>> listModels() async => const [];

  @override
  Future<List<SuggestedRecipe>> suggestRecipes(
      List<Ingredient> inventory, RecipeConstraints constraints) async {
    suggestCalls.add(constraints);
    if (suggestError != null) throw suggestError!;
    return suggestResult;
  }

  @override
  Future<List<DetectedIngredient>> recognizeIngredients(
          List<Uint8List> images) =>
      throw UnimplementedError();
}
