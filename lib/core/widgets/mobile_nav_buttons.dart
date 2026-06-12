import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// モバイル画面ヘッダー用の角丸アイコンボタン（42×42・カード背景）。
class MobileNavIconButton extends StatelessWidget {
  const MobileNavIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Icon(icon, size: 19, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// 戻る（pop）専用のナビボタン。
class MobileNavBackButton extends StatelessWidget {
  const MobileNavBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileNavIconButton(
      icon: Icons.arrow_back_ios_new,
      onTap: () => Navigator.of(context).maybePop(),
    );
  }
}
