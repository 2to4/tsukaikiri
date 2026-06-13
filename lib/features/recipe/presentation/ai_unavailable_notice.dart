import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// AI 機能（献立提案・カメラ登録）がこの端末で使えないときの案内。
///
/// 既定の文言は `aiStatusProvider` から出し分ける:
///   - [AiStatus.cloudKeyMissing]: クラウド選択だがキー未登録/無効
///     → キー登録 or オンデバイス切替を促す
///   - それ以外（[AiStatus.unavailable]）: オンデバイス非対応かつキー無し
/// [title]/[body] を渡すとそちらを優先する（カメラの「AI は使えるが画像認識に
/// 非対応」など、状態に依らない文言を出したいとき）。
/// 在庫・買い物リストなど AI 非依存の機能は通常どおり使える旨も伝える。
class AiUnavailableNotice extends ConsumerWidget {
  const AiUnavailableNotice({super.key, this.title, this.body});

  /// 見出しの上書き（未指定なら状態に応じた既定）。
  final String? title;

  /// 本文の上書き（未指定なら状態に応じた既定）。
  final String? body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(aiStatusProvider).maybeWhen(
          data: (s) => s,
          orElse: () => AiStatus.unavailable,
        );
    final cloudKeyMissing = status == AiStatus.cloudKeyMissing;
    final effectiveTitle = title ??
        (cloudKeyMissing
            ? l10n.aiCloudKeyMissingTitle
            : l10n.aiUnavailableTitle);
    final effectiveBody = body ??
        (cloudKeyMissing ? l10n.aiCloudKeyMissingBody : l10n.aiUnavailableBody);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_outlined,
                size: 48, color: AppColors.faint),
            const SizedBox(height: 16),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                effectiveBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sub,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
