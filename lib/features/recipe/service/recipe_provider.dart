import 'dart:typed_data';

import '../../../core/db/app_database.dart';
import '../domain/ai_model.dart';
import '../domain/detected_ingredient.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';

/// AI プロバイダ共通インターフェース。
/// Claude / Gemini / OpenAI / Grok で実装を差し替える。
abstract class RecipeProvider {
  /// UI に表示するプロバイダ名（例: 'Gemini'）。
  String get displayName;

  /// 使用中のモデル ID。
  /// ユーザーが未選択の間はプロバイダ実装のフォールバック既定値。
  String get modelId;

  /// 利用可能なモデル一覧をプロバイダの API から取得する。
  /// 設定画面でのモデル選択に使う（モデル名はハードコードしない）。
  Future<List<AiModel>> listModels();

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

/// AI プロバイダ API の呼び出し失敗を表す共通例外。
/// [statusCode] が 0 のときは HTTP 異常ではなくレスポンス形式の異常。
class RecipeProviderException implements Exception {
  const RecipeProviderException(this.provider, this.statusCode, this.body);

  /// プロバイダ識別子（'gemini' / 'claude' / 'openai' / 'grok'）。
  final String provider;
  final int statusCode;
  final String body;

  @override
  String toString() => 'RecipeProviderException($provider, $statusCode): $body';
}
