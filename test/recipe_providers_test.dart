import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tsukaikiri/core/db/app_database.dart';
import 'package:tsukaikiri/features/inventory/domain/ingredient_category.dart';
import 'package:tsukaikiri/features/recipe/domain/recipe_constraints.dart';
import 'package:tsukaikiri/features/recipe/service/claude_provider.dart';
import 'package:tsukaikiri/features/recipe/service/gemini_provider.dart';
import 'package:tsukaikiri/features/recipe/service/openai_compatible_provider.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_prompts.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_provider.dart';
import 'package:tsukaikiri/features/recipe/service/recipe_provider_factory.dart';
import 'package:tsukaikiri/features/settings/domain/appliance.dart';

Ingredient ingredient({
  required String name,
  double quantity = 1,
  String unit = 'piece',
  DateTime? expiry,
}) =>
    Ingredient(
      id: name,
      name: name,
      normalizedName: name,
      category: IngredientCategory.vegetable,
      quantity: quantity,
      unit: unit,
      expiryDate: expiry,
      updatedAt: DateTime(2026, 6, 10),
    );

const recipesJson =
    '{"recipes":[{"title":"肉じゃが","ingredients":[{"name":"じゃがいも","amount":"2個"}],'
    '"appliance":"hotcook","cookMode":"煮物","cookMinutes":35,"steps":["切る","煮る"],'
    '"usesExpiringSoon":true}]}';

void main() {
  group('recipe_prompts', () {
    test('buildSuggestPrompt は期限間近を強調し家電と条件を含める', () {
      final now = DateTime(2026, 6, 10);
      final prompt = buildSuggestPrompt(
        [
          ingredient(name: '豚肉', expiry: DateTime(2026, 6, 11)),
          ingredient(name: '玉ねぎ', expiry: DateTime(2026, 6, 20)),
          ingredient(name: '塩'),
        ],
        const RecipeConstraints(
          appliances: [Appliance(type: ApplianceType.hotcook)],
          outputLocale: 'en',
          extraRequest: 'あと1品',
          count: 2,
        ),
        now: now,
      );
      expect(prompt, contains('- 豚肉 1.0piece【期限間近1日】'));
      expect(prompt, contains('- 玉ねぎ 1.0piece（あと10日）'));
      expect(prompt, contains('- 塩 1.0piece\n'));
      expect(prompt, contains('hotcook'));
      expect(prompt, contains('2案'));
      expect(prompt, contains('追加条件: あと1品'));
      expect(prompt, contains('English'));
    });

    test('extractJson はコードフェンスや前置きを除去する', () {
      expect(extractJson('```json\n{"a":1}\n```'), '{"a":1}');
      expect(extractJson('以下が結果です。{"a":{"b":2}}'), '{"a":{"b":2}}');
      expect(() => extractJson('JSONなし'), throwsFormatException);
    });

    test('parseSuggestResponse は献立をパースする', () {
      final recipes = parseSuggestResponse(recipesJson);
      expect(recipes, hasLength(1));
      expect(recipes.first.title, '肉じゃが');
      expect(recipes.first.appliance, 'hotcook');
      expect(recipes.first.usesExpiringSoon, isTrue);
    });
  });

  group('GeminiProvider', () {
    test('suggestRecipes は generateContent に JSON 強制付きで POST する', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': recipesJson}
                  ]
                }
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final provider = GeminiProvider(apiKey: 'KEY', client: client);
      final recipes = await provider.suggestRecipes(
        [ingredient(name: '豚肉')],
        const RecipeConstraints(outputLocale: 'ja'),
      );
      expect(recipes.single.title, '肉じゃが');
      expect(captured.url.toString(),
          contains('models/gemini-2.0-flash:generateContent'));
      expect(captured.url.queryParameters['key'], 'KEY');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['generationConfig']['responseMimeType'], 'application/json');
    });

    test('listModels は generateContent 対応モデルだけ返す', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response(
          jsonEncode({
            'models': [
              {
                'name': 'models/gemini-2.0-flash',
                'displayName': 'Gemini 2.0 Flash',
                'supportedGenerationMethods': ['generateContent'],
              },
              {
                'name': 'models/embedding-001',
                'displayName': 'Embedding',
                'supportedGenerationMethods': ['embedContent'],
              },
            ]
          }),
          200,
        );
      });
      final models =
          await GeminiProvider(apiKey: 'KEY', client: client).listModels();
      expect(models, hasLength(1));
      expect(models.single.id, 'gemini-2.0-flash');
      expect(models.single.displayName, 'Gemini 2.0 Flash');
    });

    test('HTTP エラーは RecipeProviderException になる', () async {
      final client = MockClient((_) async => http.Response('quota', 429));
      final provider = GeminiProvider(apiKey: 'KEY', client: client);
      expect(
        () => provider.normalize(['鶏むね']),
        throwsA(isA<RecipeProviderException>()
            .having((e) => e.statusCode, 'statusCode', 429)
            .having((e) => e.provider, 'provider', 'gemini')),
      );
    });
  });

  group('OpenAiCompatibleProvider', () {
    http.Response chatResponse(String content) => http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': content}
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );

    test('grok は x.ai に Bearer 付きで POST し response_format を指定する',
        () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return chatResponse('{"normalized":{"鶏むね":"chicken_breast"}}');
      });
      final provider =
          OpenAiCompatibleProvider.grok(apiKey: 'XKEY', client: client);
      final result = await provider.normalize(['鶏むね']);
      expect(result, {'鶏むね': 'chicken_breast'});
      expect(captured.url.toString(), 'https://api.x.ai/v1/chat/completions');
      expect(captured.headers['Authorization'], 'Bearer XKEY');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['model'], 'grok-4.3');
      expect(body['response_format'], {'type': 'json_object'});
    });

    test('openai はモデル上書きを反映し image_url 形式で画像を送る', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return chatResponse(
            '{"ingredients":[{"name":"トマト","estimatedQuantity":3,"unit":"個","confidence":0.8}]}');
      });
      final provider = OpenAiCompatibleProvider.openai(
          apiKey: 'OKEY', model: 'gpt-5.4-mini', client: client);
      final detected = await provider
          .recognizeIngredients([Uint8List.fromList([1, 2, 3])]);
      expect(detected.single.name, 'トマト');
      expect(detected.single.confidence, 0.8);
      expect(captured.url.host, 'api.openai.com');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['model'], 'gpt-5.4-mini');
      final content = body['messages'][0]['content'] as List;
      expect(content[0]['type'], 'text');
      expect(content[1]['type'], 'image_url');
      expect(content[1]['image_url']['url'],
          startsWith('data:image/jpeg;base64,'));
    });

    test('listModels は /models の id を返す', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/v1/models');
        return http.Response(
          jsonEncode({
            'data': [
              {'id': 'grok-4.3'},
              {'id': 'grok-build-0.1'},
            ]
          }),
          200,
        );
      });
      final models = await OpenAiCompatibleProvider.grok(
              apiKey: 'XKEY', client: client)
          .listModels();
      expect(models.map((m) => m.id), ['grok-4.3', 'grok-build-0.1']);
      expect(models.first.displayName, 'grok-4.3');
    });
  });

  group('ClaudeProvider', () {
    http.Response messageResponse(String text) => http.Response(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': text}
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );

    test('suggestRecipes は Messages API に必須ヘッダ付きで POST する', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return messageResponse(recipesJson);
      });
      final provider = ClaudeProvider(apiKey: 'CKEY', client: client);
      final recipes = await provider.suggestRecipes(
        [ingredient(name: '豚肉')],
        const RecipeConstraints(outputLocale: 'ja'),
      );
      expect(recipes.single.title, '肉じゃが');
      expect(captured.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(captured.headers['x-api-key'], 'CKEY');
      expect(captured.headers['anthropic-version'], '2023-06-01');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['model'], ClaudeProvider.defaultModel);
      expect(body['max_tokens'], greaterThan(0));
    });

    test('recognizeIngredients は base64 画像ブロックを先に送る', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return messageResponse(
            '{"ingredients":[{"name":"卵","estimatedQuantity":6,"unit":"個","confidence":0.95}]}');
      });
      final provider = ClaudeProvider(apiKey: 'CKEY', client: client);
      final detected = await provider
          .recognizeIngredients([Uint8List.fromList([9, 9])]);
      expect(detected.single.name, '卵');
      final content =
          (jsonDecode(captured.body) as Map)['messages'][0]['content'] as List;
      expect(content[0]['type'], 'image');
      expect(content[0]['source']['type'], 'base64');
      expect(content[0]['source']['media_type'], 'image/jpeg');
      expect(content[1]['type'], 'text');
    });

    test('listModels は display_name 付きで返す', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/v1/models');
        expect(request.headers['x-api-key'], 'CKEY');
        return http.Response(
          jsonEncode({
            'data': [
              {'id': 'claude-opus-4-8', 'display_name': 'Claude Opus 4.8'},
            ]
          }),
          200,
        );
      });
      final models =
          await ClaudeProvider(apiKey: 'CKEY', client: client).listModels();
      expect(models.single.id, 'claude-opus-4-8');
      expect(models.single.displayName, 'Claude Opus 4.8');
    });
  });

  group('createRecipeProvider', () {
    test('識別子から正しい実装を生成しモデル上書きを反映する', () {
      expect(createRecipeProvider(providerId: 'gemini', apiKey: 'k'),
          isA<GeminiProvider>());
      expect(createRecipeProvider(providerId: 'grok', apiKey: 'k').displayName,
          'Grok');
      expect(
          createRecipeProvider(providerId: 'openai', apiKey: 'k').displayName,
          'OpenAI');
      expect(createRecipeProvider(providerId: 'claude', apiKey: 'k'),
          isA<ClaudeProvider>());
      expect(
          createRecipeProvider(
                  providerId: 'gemini', apiKey: 'k', model: 'gemini-2.5-pro')
              .modelId,
          'gemini-2.5-pro');
    });

    test('未知の識別子は ArgumentError', () {
      expect(() => createRecipeProvider(providerId: 'foo', apiKey: 'k'),
          throwsArgumentError);
    });
  });
}
