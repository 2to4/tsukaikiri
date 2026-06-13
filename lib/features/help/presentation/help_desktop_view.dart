// help_desktop_view.dart — ヘルプ / このアプリについて
// helpAbout.jsx の HelpBody を Flutter で忠実に再現。
// スクロール読み物・本文最大幅 680px 中央寄せ。

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'help_content.dart';

// ─────────────────────────────────────────────────────────────
// メインビュー
// ─────────────────────────────────────────────────────────────

/// macOS デスクトップ用ヘルプビュー。
/// ツールバーは app_shell の ShellToolbar（タイトルのみ）を使用する。
/// 検索フィールドは機能未実装のため置かない。
class HelpDesktopView extends StatelessWidget {
  const HelpDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kHelpContentMaxWidth),
            child: const HelpContent(),
          ),
        ),
      ),
    );
  }
}


