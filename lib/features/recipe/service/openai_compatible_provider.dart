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

/// OpenAI 互換 API（Chat Completions）を使った RecipeProvider 実装。
/// エンドポイント URL とキーの差し替えだけで OpenAI / Grok の両方に使う。
class OpenAiCompatibleProvider implements RecipeProvider {
  OpenAiCompatibleProvider({
    required this.apiKey,
    required this.baseUrl,
    required String fallbackModel,
    required this.displayName,
    required this.providerId,
    String? model,
    http.Client? client,
  })  : _model = model ?? fallbackModel,
        _client = client ?? http.Client();

  /// Grok（xAI）。
  factory OpenAiCompatibleProvider.grok({
    required String apiKey,
    String? model,
    http.Client? client,
  }) =>
      OpenAiCompatibleProvider(
        apiKey: apiKey,
        baseUrl: 'https://api.x.ai/v1',
        // モデル一覧取得前・オフライン時のフォールバック。
        fallbackModel: 'grok-4.3',
        displayName: 'Grok',
        providerId: 'grok',
        model: model,
        client: client,
      );

  /// OpenAI。
  factory OpenAiCompatibleProvider.openai({
    required String apiKey,
    String? model,
    http.Client? client,
  }) =>
      OpenAiCompatibleProvider(
        apiKey: apiKey,
        baseUrl: 'https://api.openai.com/v1',
        // モデル一覧取得前・オフライン時のフォールバック。
        fallbackModel: 'gpt-5-mini',
        displayName: 'OpenAI',
        providerId: 'openai',
        model: model,
        client: client,
      );

  final String apiKey;
  @override
  final String displayName;

  /// OpenAI 互換 API のベース URL（例: 'https://api.x.ai/v1'）。
  final String baseUrl;

  /// プロバイダ識別子（'openai' / 'grok'）。例外と設定キーに使う。
  final String providerId;

  final String _model;
  final http.Client _client;

  static const _timeout = Duration(seconds: 60);

  @override
  String get modelId => _model;

  @override
  bool get supportsVision => true;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

  @override
  Future<List<AiModel>> listModels() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/models'), headers: _headers)
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw RecipeProviderException(
          providerId, response.statusCode, response.body);
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return (data['data'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        // OpenAI 互換 API は表示名を返さないので id をそのまま使う。
        .map((m) => AiModel(id: m['id'] as String))
        .toList();
  }

  @override
  Future<List<SuggestedRecipe>> suggestRecipes(
    List<Ingredient> inventory,
    RecipeConstraints constraints,
  ) async {
    final raw = await _chat(buildSuggestPrompt(inventory, constraints));
    return parseSuggestResponse(raw);
  }

  @override
  Future<Map<String, String>> normalize(List<String> names) async {
    if (names.isEmpty) return {};
    final raw = await _chat(buildNormalizePrompt(names));
    return parseNormalizeResponse(raw);
  }

  @override
  Future<List<DetectedIngredient>> recognizeIngredients(
      List<Uint8List> images) async {
    if (images.isEmpty) return [];
    final content = <Map<String, dynamic>>[
      {'type': 'text', 'text': recognizePrompt},
      ...images.map((bytes) => {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,${base64Encode(bytes)}',
            },
          }),
    ];
    final raw = await _chatWithContent(content);
    return parseRecognizeResponse(raw);
  }

  // ---- HTTP helpers ----

  Future<String> _chat(String prompt) => _chatWithContent(prompt);

  /// [content] は文字列（テキストのみ）またはマルチモーダルの parts 配列。
  Future<String> _chatWithContent(Object content) async {
    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'user', 'content': content}
      ],
      // プロンプトでの JSON 指示に加えて API 側でも JSON 出力を強制する。
      'response_format': {'type': 'json_object'},
    });
    final response = await _client
        .post(Uri.parse('$baseUrl/chat/completions'),
            headers: _headers, body: body)
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw RecipeProviderException(
          providerId, response.statusCode, response.body);
    }
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw RecipeProviderException(providerId, 0, 'No choices in response');
    }
    return choices.first['message']['content'] as String;
  }
}
