package com.futo4.tsukaikiri

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import com.google.ai.edge.aicore.GenerativeModel
import com.google.ai.edge.aicore.generationConfig
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * オンデバイス AI（Gemini Nano / AICore）への薄いブリッジ。
 *
 * channel `com.futo4.tsukaikiri/ondevice_ai`:
 *   - `availability` → {available, supportsVision, reason?}
 *   - `generate`     → モデル出力テキスト（Dart 側が JSON としてパースする）
 *
 * プロンプト生成・JSON パースは Dart 側（recipe_prompts.dart）に置き、ここは
 * 「プロンプト→テキスト」のみを担う（iOS/macOS の OnDeviceAiPlugin と同契約）。
 * 非対応端末（AICore 無し / Android 14 未満）では available=false に縮退する。
 */
class OnDeviceAiPlugin(private val appContext: Context) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.futo4.tsukaikiri/ondevice_ai"
        private const val AICORE_PACKAGE = "com.google.android.aicore"
    }

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "availability" -> result.success(availability())
            "generate" -> {
                val prompt = call.argument<String>("prompt")
                if (prompt == null) {
                    result.error("INVALID_ARGS", "prompt required", null)
                    return
                }
                generate(prompt, result)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Gemini Nano の可否を軽量に判定する（モデルのダウンロードは伴わない）。
     * AICore（システムアプリ）の存在と Android 14+ を前提に判定する。
     * 実際の生成可否は端末・モデル DL 状況に依存するため、generate 側でも例外処理する。
     */
    private fun availability(): Map<String, Any> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return mapOf(
                "available" to false,
                "supportsVision" to false,
                "reason" to "unsupported_os",
            )
        }
        val present = try {
            appContext.packageManager.getPackageInfo(AICORE_PACKAGE, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
        return if (present) {
            // 現状はテキスト専用のため supportsVision=false。
            mapOf("available" to true, "supportsVision" to false)
        } else {
            mapOf(
                "available" to false,
                "supportsVision" to false,
                "reason" to "aicore_not_available",
            )
        }
    }

    private fun generate(prompt: String, result: MethodChannel.Result) {
        scope.launch {
            var model: GenerativeModel? = null
            try {
                model = GenerativeModel(
                    generationConfig = generationConfig {
                        context = appContext
                        temperature = 0.2f
                        topK = 16
                        maxOutputTokens = 1024
                    },
                )
                val response = model.generateContent(prompt)
                val text = response.text
                if (text.isNullOrEmpty()) {
                    result.error("empty", "empty response", null)
                } else {
                    result.success(text)
                }
            } catch (e: Exception) {
                result.error("generate_failed", e.message ?: e.toString(), null)
            } finally {
                model?.close()
            }
        }
    }
}
