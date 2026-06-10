import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/db/app_database.dart';
import '../domain/detected_ingredient.dart';
import '../domain/recipe_constraints.dart';
import '../domain/suggested_recipe.dart';
import 'recipe_provider.dart';

/// Gemini Flash を使った RecipeProvider 実装。
/// API キーは呼び出し元から渡す（SecureStorageService で取得して渡す）。
class GeminiProvider implements RecipeProvider {
  GeminiProvider({
    required this.apiKey,
    String? model,
  }) : _model = model ?? 'gemini-2.0-flash';

  final String apiKey;
  final String _model;

  static const _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  @override
  String get displayName => 'Gemini Flash';

  @override
  String get modelId => _model;

  @override
  bool get supportsVision => true;

  // ---- suggestRecipes ----

  @override
  Future<List<SuggestedRecipe>> suggestRecipes(
    List<Ingredient> inventory,
    RecipeConstraints constraints,
  ) async {
    final prompt = _buildSuggestPrompt(inventory, constraints);
    final raw = await _generateText(prompt);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['recipes'] as List)
        .map((e) => SuggestedRecipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _buildSuggestPrompt(
      List<Ingredient> inventory, RecipeConstraints constraints) {
    final lang = constraints.outputLocale == 'ja' ? '日本語' : 'English';
    final now = DateTime.now();
    final inventoryLines = inventory.map((i) {
      final daysLeft = i.expiryDate?.difference(now).inDays;
      final expiryNote = daysLeft != null
          ? (daysLeft <= 2 ? '【期限間近$daysLeft日】' : '（あと$daysLeft日）')
          : '';
      return '- ${i.name} ${i.quantity}${i.unit}$expiryNote';
    }).join('\n');

    final applianceLines = constraints.appliances.isEmpty
        ? '（なし）'
        : constraints.appliances.map((a) => a.type.name).join(', ');

    final extra =
        constraints.extraRequest != null ? '\n追加条件: ${constraints.extraRequest}' : '';

    return '''
以下の在庫と条件で献立を${constraints.count}案提案してください。
期限間近の食材を優先して使ってください。$extra

【在庫】
$inventoryLines

【所有家電】
$applianceLines

返答は以下のJSON形式のみ。前置き・コードフェンス・説明文は一切禁止。
フィールド名は変えず、自然文（title・steps等）は$langで生成すること。

{"recipes":[{"title":"","ingredients":[{"name":"","amount":""}],"appliance":null,"cookMode":null,"cookMinutes":null,"steps":[""],"usesExpiringSoon":false}]}
''';
  }

  // ---- normalize ----

  @override
  Future<Map<String, String>> normalize(List<String> names) async {
    if (names.isEmpty) return {};
    final prompt = '''
以下の食材名リストについて、表記ゆれを吸収した言語非依存の正規化キー（英小文字・アンダースコア区切り）を付与してください。
例: "鶏むね" → "chicken_breast", "鶏胸肉" → "chicken_breast"

返答はJSON形式のみ。前置き禁止。
{"normalized":{"<元の名前>":"<キー>", ...}}

食材リスト:
${names.map((n) => '- $n').join('\n')}
''';
    final raw = await _generateText(prompt);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return Map<String, String>.from(data['normalized'] as Map);
  }

  // ---- recognizeIngredients ----

  @override
  Future<List<DetectedIngredient>> recognizeIngredients(
      List<Uint8List> images) async {
    if (images.isEmpty) return [];
    final parts = <Map<String, dynamic>>[
      {
        'text': '''
冷蔵庫内の画像から食材を検出してください。
返答はJSON形式のみ。前置き禁止。
{"ingredients":[{"name":"","estimatedQuantity":1,"unit":"個","confidence":0.9}]}
'''
      },
      ...images.map((bytes) => {
            'inline_data': {
              'mime_type': 'image/jpeg',
              'data': base64Encode(bytes),
            }
          }),
    ];
    final raw = await _generateWithParts(parts);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['ingredients'] as List)
        .map((e) => DetectedIngredient.fromJson(e as Map<String, dynamic>))
        .toList();
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
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw GeminiApiException(response.statusCode, response.body);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw const GeminiApiException(0, 'No candidates in response');
    }
    return candidates.first['content']['parts'][0]['text'] as String;
  }
}

class GeminiApiException implements Exception {
  const GeminiApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'GeminiApiException($statusCode): $body';
}
