import 'package:http/http.dart' as http;

import 'claude_provider.dart';
import 'gemini_provider.dart';
import 'openai_compatible_provider.dart';
import 'recipe_provider.dart';

/// 設定可能な AI プロバイダの識別子（実装優先順位順）。
const supportedProviderIds = ['gemini', 'grok', 'openai', 'claude'];

/// プロバイダ識別子から RecipeProvider 実装を生成する。
/// [model] が null のときは各実装のフォールバック既定値を使う
/// （実際の選択肢は RecipeProvider.listModels で API から取得する）。
RecipeProvider createRecipeProvider({
  required String providerId,
  required String apiKey,
  String? model,
  http.Client? client,
}) {
  switch (providerId) {
    case 'gemini':
      return GeminiProvider(apiKey: apiKey, model: model, client: client);
    case 'grok':
      return OpenAiCompatibleProvider.grok(
          apiKey: apiKey, model: model, client: client);
    case 'openai':
      return OpenAiCompatibleProvider.openai(
          apiKey: apiKey, model: model, client: client);
    case 'claude':
      return ClaudeProvider(apiKey: apiKey, model: model, client: client);
    default:
      throw ArgumentError.value(providerId, 'providerId', '未知の AI プロバイダ');
  }
}
