import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// AI 機能（献立提案・カメラ登録）がこの端末で使えないときの案内。
///
/// オンデバイス AI 非対応かつ自前キー未登録（`aiAvailableProvider` が false）の
/// ときに、AI 専用画面（献立提案・カメラ登録）で入口の代わりに表示する。
/// 在庫・買い物リストなど AI 非依存の機能は通常どおり使える旨も伝える。
class AiUnavailableNotice extends StatelessWidget {
  const AiUnavailableNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              l10n.aiUnavailableTitle,
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
                l10n.aiUnavailableBody,
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
