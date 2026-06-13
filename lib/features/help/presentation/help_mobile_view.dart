// help_mobile_view.dart
// モバイル（狭い幅）向けヘルプ / このアプリについて 画面。
//
// 設定画面から push で開くフルページ。
// ロジックは desktop と共有（HelpContent）。

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mobile_nav_buttons.dart';
import '../../../l10n/app_localizations.dart';
import 'help_content.dart';

/// モバイル向けヘルプ画面。
/// Scaffold + 戻るボタン + スクロール本文。
class HelpMobileView extends StatelessWidget {
  const HelpMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: MobileNavBackButton(),
        ),
        title: Text(
          l10n.shellNavHelp,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: const HelpContent(),
      ),
    );
  }
}
