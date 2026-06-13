import 'dart:io';

import 'package:http/http.dart' as http;

import 'claude_provider.dart';
import 'gemini_provider.dart';
import 'openai_compatible_provider.dart';
import 'recipe_provider.dart';

/// 設定可能なクラウド AI プロバイダの識別子（実装優先順位順）。
/// `createRecipeProvider` で生成できるもの（自前キーが要る）。
const supportedProviderIds = ['gemini', 'grok', 'openai', 'claude'];

/// オンデバイス AI（既定。キー不要）を表す selectedProvider の sentinel 値。
/// クラウド4社と異なり factory では生成せず、`recipeProviderProvider` が
/// `OnDeviceAiService` 経由で `OnDeviceRecipeProvider` を解決する。
const onDeviceProviderId = 'ondevice';

/// オンデバイス AI の表示名（プラットフォーム別のブランド名）。
/// iOS/macOS = Apple Foundation Models、Android = Gemini Nano。
String onDeviceDisplayName() =>
    Platform.isAndroid ? 'Gemini Nano' : 'Apple Intelligence';

/// API キー取得ページの URL（設定・オンボーディングの画面で共用）。
const providerKeyUrls = <String, String>{
  'gemini': 'https://aistudio.google.com/apikey',
  'grok': 'https://console.x.ai',
  'openai': 'https://platform.openai.com/api-keys',
  'claude': 'https://console.anthropic.com/settings/keys',
};

/// 画面表示用のプロバイダ情報（表示名・Vision 対応）。
///
/// 未知の id（旧バージョンの設定や壊れたバックアップ由来）でも throw せず
/// フォールバックを返す — 設定画面自体が開けなくなるのを防ぐため。
({String displayName, bool supportsVision}) providerDisplayInfo(String id) {
  if (id == onDeviceProviderId) {
    // Vision 可否は実機の availability で決まるためここでは false 既定。
    return (displayName: onDeviceDisplayName(), supportsVision: false);
  }
  if (!supportedProviderIds.contains(id)) {
    return (displayName: id, supportsVision: false);
  }
  final p = createRecipeProvider(providerId: id, apiKey: '');
  return (displayName: p.displayName, supportsVision: p.supportsVision);
}

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
