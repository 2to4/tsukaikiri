import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// 賞味期限の警告レベル。
/// 決定: 残り3日以内＝警告色 / 当日・超過＝赤 / 期限切れ品は一覧に残す。
enum ExpiryLevel { none, expired, today, warning, normal }

class ExpiryInfo {
  const ExpiryInfo(this.level, this.daysLeft);
  final ExpiryLevel level;

  /// 残り日数（カレンダー日基準）。期限なしのときは null。
  final int? daysLeft;
}

/// 期限と現在日時から警告レベルを求める（カレンダー日で比較）。
ExpiryInfo expiryInfoFor(DateTime? expiry, DateTime now) {
  if (expiry == null) return const ExpiryInfo(ExpiryLevel.none, null);
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(expiry.year, expiry.month, expiry.day);
  final days = due.difference(today).inDays;
  final level = switch (days) {
    < 0 => ExpiryLevel.expired,
    0 => ExpiryLevel.today,
    <= 3 => ExpiryLevel.warning,
    _ => ExpiryLevel.normal,
  };
  return ExpiryInfo(level, days);
}

extension ExpiryInfoX on ExpiryInfo {
  String label(AppLocalizations l10n) => switch (level) {
        ExpiryLevel.none => l10n.expiryNone,
        ExpiryLevel.expired => l10n.expiryExpired,
        ExpiryLevel.today => l10n.expiryToday,
        ExpiryLevel.warning ||
        ExpiryLevel.normal =>
          l10n.expiryInDays(daysLeft ?? 0),
      };

  Color color(ColorScheme scheme) => switch (level) {
        ExpiryLevel.expired || ExpiryLevel.today => scheme.error,
        ExpiryLevel.warning => Colors.orange.shade700,
        ExpiryLevel.normal => scheme.onSurfaceVariant,
        ExpiryLevel.none => scheme.outline,
      };
}
