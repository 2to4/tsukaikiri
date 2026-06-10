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

/// Claude（Anthropic Messages API）を使った RecipeProvider 実装（REST 直叩き）。
class ClaudeProvider implements RecipeProvider {
  ClaudeProvider({
    required this.apiKey,
    String? model,
    http.Client? client,
  })  : _model = model ?? defaultModel,
        _client = client ?? http.Client();

  /// モデル一覧取得前・オフライン時のフォールバック。
  /// 実際の選択肢は [listModels] で API から取得する。
  static const defaultModel = 'claude-opus-4-8';

  final String apiKey;
  final String _model;
  final http.Client _client;

  static const _base = 'https://api.anthropic.com/v1';
  static const _timeout = Duration(seconds: 60);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      };

  @override
  String get displayName => 'Claude';

  @override
  String get modelId => _model;

  @override
  bool get supportsVision => true;

  @override
  Future<List<AiModel>> listModels() async {
    final response = await _client
        .get(Uri.parse('$_base/models'), headers: _headers)
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw RecipeProviderException('claude', response.statusCode, response.body);
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return (data['data'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((m) => AiModel(
              id: m['id'] as String,
              displayName: m['display_name'] as String?,
            ))
        .toList();
  }

  @override
  Future<List<SuggestedRecipe>> suggestRecipes(
    List<Ingredient> inventory,
    RecipeConstraints constraints,
  ) async {
    final raw = await _messageText(buildSuggestPrompt(inventory, constraints));
    return parseSuggestResponse(raw);
  }

  @override
  Future<Map<String, String>> normalize(List<String> names) async {
    if (names.isEmpty) return {};
    final raw = await _messageText(buildNormalizePrompt(names));
    return parseNormalizeResponse(raw);
  }

  @override
  Future<List<DetectedIngredient>> recognizeIngredients(
      List<Uint8List> images) async {
    if (images.isEmpty) return [];
    final content = <Map<String, dynamic>>[
      // 画像を先・指示テキストを後にするのが Anthropic の推奨。
      ...images.map((bytes) => {
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': 'image/jpeg',
              'data': base64Encode(bytes),
            },
          }),
      {'type': 'text', 'text': recognizePrompt},
    ];
    final raw = await _message(content);
    return parseRecognizeResponse(raw);
  }

  // ---- HTTP helpers ----

  Future<String> _messageText(String prompt) =>
      _message([{'type': 'text', 'text': prompt}]);

  Future<String> _message(List<Map<String, dynamic>> content) async {
    final body = jsonEncode({
      'model': _model,
      'max_tokens': 16000,
      'messages': [
        {'role': 'user', 'content': content}
      ],
    });
    final response = await _client
        .post(Uri.parse('$_base/messages'), headers: _headers, body: body)
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw RecipeProviderException('claude', response.statusCode, response.body);
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final blocks = (data['content'] as List? ?? []).cast<Map<String, dynamic>>();
    final text = blocks.firstWhere(
      (b) => b['type'] == 'text',
      orElse: () => throw const RecipeProviderException(
          'claude', 0, 'No text block in response'),
    )['text'] as String;
    return text;
  }
}
