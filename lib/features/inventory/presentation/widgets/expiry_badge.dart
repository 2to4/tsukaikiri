import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../expiry_status.dart';

/// 賞味期限の状態を「色ドット＋数字」で表すバッジ（Claude Design 準拠）。
class ExpiryBadge extends StatelessWidget {
  const ExpiryBadge({super.key, required this.expiry, this.large = false});

  final DateTime? expiry;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = expiryInfoFor(expiry, DateTime.now());
    final color = info.badgeColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 11 : 9,
        vertical: large ? 6 : 5,
      ),
      decoration: BoxDecoration(
        color: info.badgeSoftColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            info.label(l10n),
            style: TextStyle(
              fontSize: large ? 14 : 12.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
