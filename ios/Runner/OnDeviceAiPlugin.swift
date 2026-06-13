import Foundation

#if canImport(FlutterMacOS)
import FlutterMacOS
#elseif canImport(Flutter)
import Flutter
#endif

#if canImport(FoundationModels)
import FoundationModels
#endif

/// オンデバイス AI（Apple Foundation Models）への薄いブリッジ。
///
/// channel `com.futo4.tsukaikiri/ondevice_ai`:
///   - `availability` → {available, supportsVision, reason?}
///   - `generate`     → モデル出力テキスト（Dart 側が JSON としてパースする）
///
/// プロンプト生成・JSON パースは Dart 側（recipe_prompts.dart）に置き、ここは
/// 「プロンプト→テキスト」のみを担う。FoundationModels 非対応 SDK / OS では
/// コンパイル・実行とも安全に縮退（available=false を返す）。
///
/// ⚠️ 同期必須: macOS / iOS で同一実装（Flutter import と messenger の差は条件
/// コンパイルで吸収）。`ios/Runner/OnDeviceAiPlugin.swift` と
/// `macos/Runner/OnDeviceAiPlugin.swift` は完全に同一内容に保つこと。別 Xcode
/// プロジェクトのため、一方だけ変更してもコンパイラは乖離を検知しない。
class OnDeviceAiPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
    let messenger = registrar.messenger()
    #else
    let messenger = registrar.messenger
    #endif
    let channel = FlutterMethodChannel(
      name: "com.futo4.tsukaikiri/ondevice_ai",
      binaryMessenger: messenger
    )
    registrar.addMethodCallDelegate(OnDeviceAiPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "availability":
      result(availability())
    case "generate":
      guard let args = call.arguments as? [String: Any],
            let prompt = args["prompt"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "prompt required", details: nil))
        return
      }
      generate(prompt: prompt, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - availability

  private func availability() -> [String: Any] {
    #if canImport(FoundationModels)
    if #available(macOS 26.0, iOS 26.0, *) {
      // 現状のオンデバイス基盤モデルはテキスト専用のため supportsVision=false
      // （画像理解は Vision framework / 将来のマルチモーダルモデルが必要）。
      switch SystemLanguageModel.default.availability {
      case .available:
        return ["available": true, "supportsVision": false]
      case .unavailable(let reason):
        return [
          "available": false,
          "supportsVision": false,
          "reason": Self.reasonString(reason),
        ]
      @unknown default:
        return ["available": false, "supportsVision": false, "reason": "unavailable"]
      }
    }
    #endif
    return ["available": false, "supportsVision": false, "reason": "unsupported_os"]
  }

  #if canImport(FoundationModels)
  @available(macOS 26.0, iOS 26.0, *)
  private static func reasonString(
    _ reason: SystemLanguageModel.Availability.UnavailableReason
  ) -> String {
    switch reason {
    case .deviceNotEligible:
      return "device_not_eligible"
    case .appleIntelligenceNotEnabled:
      return "apple_intelligence_not_enabled"
    case .modelNotReady:
      return "model_not_ready"
    @unknown default:
      return "unavailable"
    }
  }
  #endif

  // MARK: - generate

  private func generate(prompt: String, result: @escaping FlutterResult) {
    #if canImport(FoundationModels)
    if #available(macOS 26.0, iOS 26.0, *) {
      Task {
        do {
          let session = LanguageModelSession()
          let response = try await session.respond(to: prompt)
          // String は Sendable。Response<String> ごとクロージャに渡さない（Swift 6 対策）。
          let content = response.content
          await MainActor.run { result(content) }
        } catch {
          await MainActor.run {
            result(FlutterError(
              code: "generate_failed",
              message: error.localizedDescription,
              details: nil))
          }
        }
      }
      return
    }
    #endif
    result(FlutterError(
      code: "unavailable",
      message: "on-device model is not available on this platform",
      details: nil))
  }
}
