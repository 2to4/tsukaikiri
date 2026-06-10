import 'dart:typed_data';

import '../../../core/db/app_database.dart';
import '../domain/detected_ingredient.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';

/// AI プロバイダ共通インターフェース。
/// Claude / Gemini / OpenAI / Grok で実装を差し替える。
abstract class RecipeProvider {
  /// UI に表示するプロバイダ名（例: 'Gemini Flash'）。
  String get displayName;

  /// 使用モデル ID。
  String get modelId;

  /// 画像入力（Vision）に対応しているか。
  /// false の場合は recognizeIngredients が UnsupportedError を投げる。
  bool get supportsVision;

  /// 在庫をもとに献立を提案する。
  Future<List<SuggestedRecipe>> suggestRecipes(
    List<Ingredient> inventory,
    RecipeConstraints constraints,
  );

  /// 食材名のリストを正規化キーにマッピングする。
  /// 戻り値: {表示名 → normalizedName} のマップ。
  Future<Map<String, String>> normalize(List<String> names);

  /// 画像から食材候補を検出する（カメラ登録用）。
  Future<List<DetectedIngredient>> recognizeIngredients(List<Uint8List> images);
}
