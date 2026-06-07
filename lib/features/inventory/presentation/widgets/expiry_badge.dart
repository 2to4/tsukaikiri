import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../expiry_status.dart';

/// 賞味期限の状態を色付きチップで表示する。
class ExpiryBadge extends StatelessWidget {
  const ExpiryBadge({super.key, required this.expiry});

  final DateTime? expiry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final info = expiryInfoFor(expiry, DateTime.now());
    final color = info.color(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        info.label(l10n),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
