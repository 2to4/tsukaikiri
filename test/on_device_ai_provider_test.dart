import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tsukaikiri/features/recipe/domain/recipe_constraints.dart';
import 'package:tsukaikiri/features/recipe/service/apple_foundation_models_provider.dart';
import 'package:tsukaikiri/features/recipe/service/on_device_ai_service.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_provider.dart';

/// プロンプトを無視して固定テキストを返す／例外を投げるフェイク。
class _FakeOnDeviceAiService extends OnDeviceAiService {
  _FakeOnDeviceAiService({this.response, this.error});

  final String? response;
  final Object? error;

  String? lastPrompt;
  List<Uint8List>? lastImages;

  @override
  Future<String> generate({
    required String prompt,
    List<Uint8List> images = const [],
  }) async {
    lastPrompt = prompt;
    lastImages = images;
    if (error != null) throw error!;
    return response!;
  }
}

void main() {
  const constraints = RecipeConstraints(outputLocale: 'ja');

  test('メタ情報: displayName / modelId / supportsVision / listModels', () async {
    final p = AppleFoundationModelsProvider(
      service: _FakeOnDeviceAiService(response: '{}'),
      supportsVision: true,
    );
    expect(p.displayName, 'Apple Intelligence');
    expect(p.modelId, 'apple-foundation-models');
    expect(p.supportsVision, isTrue);
    final models = await p.listModels();
    expect(models, hasLength(1));
    expect(models.single.id, 'apple-foundation-models');
  });

  test('suggestRecipes: 生成テキストを既存パーサで SuggestedRecipe に変換', () async {
    final fake = _FakeOnDeviceAiService(
      response:
          '{"recipes":[{"title":"親子丼","ingredients":[{"name":"鶏肉","amount":"100g"}],'
          '"appliance":null,"cookMode":null,"cookMinutes":15,"steps":["切る","煮る"],'
          '"usesExpiringSoon":true}]}',
    );
    final p = AppleFoundationModelsProvider(service: fake);
    final recipes = await p.suggestRecipes(const [], constraints);
    expect(recipes, hasLength(1));
    expect(recipes.single.title, '親子丼');
    expect(recipes.single.steps, ['切る', '煮る']);
    // プロンプトは recipe_prompts 経由で生成されている（JSON 指示を含む）。
    expect(fake.lastPrompt, contains('JSON'));
  });

  test('normalize: {normalized:{...}} をマップに変換', () async {
    final p = AppleFoundationModelsProvider(
      service: _FakeOnDeviceAiService(
        response: '{"normalized":{"鶏むね":"chicken_breast"}}',
      ),
    );
    final map = await p.normalize(['鶏むね']);
    expect(map['鶏むね'], 'chicken_breast');
  });

  test('recognizeIngredients: supportsVision=false なら UnsupportedError', () async {
    final p = AppleFoundationModelsProvider(
      service: _FakeOnDeviceAiService(response: '{}'),
      supportsVision: false,
    );
    expect(
      () => p.recognizeIngredients([Uint8List(0)]),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('recognizeIngredients: supportsVision=true なら候補を返し画像が渡る', () async {
    final fake = _FakeOnDeviceAiService(
      response:
          '{"ingredients":[{"name":"牛乳","estimatedQuantity":1,"unit":"本","confidence":0.9}]}',
    );
    final p = AppleFoundationModelsProvider(service: fake, supportsVision: true);
    final detected = await p.recognizeIngredients([Uint8List.fromList([1, 2, 3])]);
    expect(detected, hasLength(1));
    expect(detected.single.name, '牛乳');
    expect(fake.lastImages, hasLength(1));
  });

  test('生成失敗(OnDeviceAiException) → RecipeProviderException(statusCode 0)', () async {
    final p = AppleFoundationModelsProvider(
      service: _FakeOnDeviceAiService(
        error: const OnDeviceAiException('model error', code: 'generate_failed'),
      ),
    );
    await expectLater(
      p.suggestRecipes(const [], constraints),
      throwsA(isA<RecipeProviderException>()
          .having((e) => e.provider, 'provider', 'ondevice')
          .having((e) => e.statusCode, 'statusCode', 0)),
    );
  });

  test('壊れた JSON(FormatException) → RecipeProviderException(statusCode 0)', () async {
    final p = AppleFoundationModelsProvider(
      service: _FakeOnDeviceAiService(response: 'これはJSONではありません'),
    );
    await expectLater(
      p.suggestRecipes(const [], constraints),
      throwsA(isA<RecipeProviderException>()
          .having((e) => e.statusCode, 'statusCode', 0)),
    );
  });
}
