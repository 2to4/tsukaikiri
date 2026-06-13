import 'package:flutter/services.dart';

/// オンデバイス AI の可用性。
///
/// [available] が false のときはオンデバイス AI を使えない
/// （未対応 OS / Apple Intelligence 無効 / モデル未ダウンロードなど。理由は [reason]）。
class OnDeviceAiAvailability {
  const OnDeviceAiAvailability({
    required this.available,
    required this.supportsVision,
    this.reason,
  });

  final bool available;

  /// 画像入力（カメラ登録）に対応しているか。
  final bool supportsVision;

  /// 使えない場合の理由（ネイティブ側が返す識別子。UI 案内に利用可）。
  final String? reason;

  static const unavailable =
      OnDeviceAiAvailability(available: false, supportsVision: false);
}

/// オンデバイス AI ネイティブ実装への薄いブリッジ。
///
/// platform channel `com.futo4.tsukaikiri/ondevice_ai` 経由で macOS / iOS の
/// [OnDeviceAiPlugin]（Apple Foundation Models）を呼ぶ。プロンプト生成・JSON
/// パースは Dart 側（`recipe_prompts.dart`）に置き、ネイティブ側は「プロンプト
/// →テキスト」のみを担う。
class OnDeviceAiService {
  const OnDeviceAiService({MethodChannel? channel})
      : _channel = channel ?? _defaultChannel;

  static const _defaultChannel =
      MethodChannel('com.futo4.tsukaikiri/ondevice_ai');

  final MethodChannel _channel;

  /// オンデバイス AI が使えるか・Vision 対応かを問い合わせる。
  /// プラグイン未登録（未対応プラットフォーム）でも例外を投げず unavailable を返す。
  Future<OnDeviceAiAvailability> availability() async {
    try {
      final res =
          await _channel.invokeMapMethod<String, dynamic>('availability');
      if (res == null) return OnDeviceAiAvailability.unavailable;
      return OnDeviceAiAvailability(
        available: res['available'] == true,
        supportsVision: res['supportsVision'] == true,
        reason: res['reason'] as String?,
      );
    } on PlatformException catch (e) {
      return OnDeviceAiAvailability(
          available: false, supportsVision: false, reason: e.code);
    } on MissingPluginException {
      return OnDeviceAiAvailability.unavailable;
    }
  }

  /// プロンプト（+任意で画像）をオンデバイスモデルに渡し、生成テキストを返す。
  Future<String> generate({
    required String prompt,
    List<Uint8List> images = const [],
  }) async {
    try {
      final res = await _channel.invokeMethod<String>('generate', {
        'prompt': prompt,
        if (images.isNotEmpty) 'images': images,
      });
      if (res == null || res.isEmpty) {
        throw const OnDeviceAiException('empty response', code: 'empty');
      }
      return res;
    } on PlatformException catch (e) {
      throw OnDeviceAiException(e.message ?? e.code, code: e.code);
    } on MissingPluginException {
      throw const OnDeviceAiException('on-device AI not available',
          code: 'unavailable');
    }
  }
}

/// オンデバイス AI 呼び出しの失敗。
class OnDeviceAiException implements Exception {
  const OnDeviceAiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'OnDeviceAiException(${code ?? '-'}): $message';
}
