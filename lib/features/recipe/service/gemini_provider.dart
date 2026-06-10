import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/db/app_database.dart';
import '../domain/ai_model.dart';
import '../domain/detected_ingredient.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';
import 'recipe_prompts.dart';
import 'recipe_provider.dart';

/// Gemini を使った RecipeProvider 実装（REST 直叩き）。
/// API キーは呼び出し元から渡す（SecureStorageService で取得して渡す）。
class GeminiProvider implements RecipeProvider {
  GeminiProvider({
    required this.apiKey,
    String? model,
    http.Client? client,
  })  : _model = model ?? defaultModel,
        _client = client ?? http.Client();

  /// モデル一覧取得前・オフライン時のフォールバック。
  /// 実際の選択肢は [listModels] で API から取得する。
  static const defaultModel = 'gemini-2.0-flash';

  final String apiKey;
  final String _model;
  final http.Client _client;

  static const _base =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const _timeout = Duration(seconds: 60);

  @override
  String get displayName => 'Gemini';

  @override
  String get modelId => _model;

  @override
  bool get supportsVision => true;

  @override
  Future<List<AiModel>> listModels() async {
    final response = await _client
        .get(Uri.parse('$_base?key=$apiKey'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw RecipeProviderException('gemini', response.statusCode, response.body);
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return (data['models'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        // 献立提案に使えるのはテキスト生成対応モデルのみ。
        .where((m) => (m['supportedGenerationMethods'] as List? ?? [])
            .contains('generateContent'))
        .map((m) => AiModel(
              // name は 'models/gemini-2.0-flash' 形式で返る。
              id: (m['name'] as String).replaceFirst('models/', ''),
              displayName: m['displayName'] as String?,
            ))
        .toList();
  }

  @override
  Future<List<SuggestedRecipe>> suggestRecipes(
    List<Ingredient> inventory,
    RecipeConstraints constraints,
  ) async {
    final raw = await _generateText(buildSuggestPrompt(inventory, constraints));
    return parseSuggestResponse(raw);
  }

  @override
  Future<Map<String, String>> normalize(List<String> names) async {
    if (names.isEmpty) return {};
    final raw = await _generateText(buildNormalizePrompt(names));
    return parseNormalizeResponse(raw);
  }

  @override
  Future<List<DetectedIngredient>> recognizeIngredients(
      List<Uint8List> images) async {
    if (images.isEmpty) return [];
    final parts = <Map<String, dynamic>>[
      {'text': recognizePrompt},
      ...images.map((bytes) => {
            'inline_data': {
              'mime_type': 'image/jpeg',
              'data': base64Encode(bytes),
            }
          }),
    ];
    final raw = await _generateWithParts(parts);
    return parseRecognizeResponse(raw);
  }

  // ---- HTTP helpers ----

  Future<String> _generateText(String prompt) =>
      _generateWithParts([{'text': prompt}]);

  Future<String> _generateWithParts(
      List<Map<String, dynamic>> parts) async {
    final url = Uri.parse('$_base/$_model:generateContent?key=$apiKey');
    final body = jsonEncode({
      'contents': [
        {'parts': parts}
      ],
      'generationConfig': {'responseMimeType': 'application/json'},
    });
    final response = await _client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw RecipeProviderException('gemini', response.statusCode, response.body);
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw const RecipeProviderException(
          'gemini', 0, 'No candidates in response');
    }
    return candidates.first['content']['parts'][0]['text'] as String;
  }
}
