import 'dart:typed_data';

import '../../../core/db/app_database.dart';
import '../domain/ai_model.dart';
import '../domain/detected_ingredient.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';
import 'on_device_ai_service.dart';
import 'recipe_prompts.dart';
import 'recipe_provider.dart';

/// Apple Foundation Models（オンデバイス LLM）による [RecipeProvider] 実装。
///
/// プロンプト生成・JSON パースは `recipe_prompts.dart` をクラウド実装と共有し、
/// ネイティブ側（[OnDeviceAiService]）は「プロンプト→テキスト」のみを担う。
/// これによりプロバイダを切り替えても挙動・スキーマが一致する。
class AppleFoundationModelsProvider implements RecipeProvider {
  AppleFoundationModelsProvider({
    required this.service,
    this.supportsVision = false,
  });

  final OnDeviceAiService service;

  /// プロバイダ識別子（クラウド4社と区別する）。
  static const providerId = 'ondevice';

  @override
  String get displayName => 'Apple Intelligence';

  @override
  String get modelId => 'apple-foundation-models';

  @override
  final bool supportsVision;

  @override
  Future<List<AiModel>> listModels() async => const [
        AiModel(
          id: 'apple-foundation-models',
          displayName: 'Apple Intelligence (オンデバイス)',
        ),
      ];

  @override
  Future<List<SuggestedRecipe>> suggestRecipes(
    List<Ingredient> inventory,
    RecipeConstraints constraints,
  ) {
    return _run(
      () async => parseSuggestResponse(
        await service.generate(
            prompt: buildSuggestPrompt(inventory, constraints)),
      ),
    );
  }

  @override
  Future<Map<String, String>> normalize(List<String> names) {
    return _run(
      () async => parseNormalizeResponse(
        await service.generate(prompt: buildNormalizePrompt(names)),
      ),
    );
  }

  @override
  Future<List<DetectedIngredient>> recognizeIngredients(
      List<Uint8List> images) {
    if (!supportsVision) {
      throw UnsupportedError('on-device model does not support vision');
    }
    return _run(
      () async => parseRecognizeResponse(
        await service.generate(prompt: recognizePrompt, images: images),
      ),
    );
  }

  /// 生成と JSON パースを実行し、失敗は共通の [RecipeProviderException] に変換する。
  /// 呼び出し失敗・形式異常とも statusCode=0（形式/オンデバイス異常）で表す。
  Future<T> _run<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on OnDeviceAiException catch (e) {
      throw RecipeProviderException(providerId, 0, e.message);
    } on FormatException catch (e) {
      throw RecipeProviderException(providerId, 0, e.message);
    }
  }
}
