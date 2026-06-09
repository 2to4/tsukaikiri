import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// アプリ全体のテーマ。Claude Design のデザイン言語に合わせる。
///
/// - 本文/UI フォント: M PLUS Rounded 1c（やわらかい丸ゴシック）
/// - ロゴ/見出しの差し色フォント: Zen Maru Gothic（[brandTextStyle] で使う）
/// - 背景はオフホワイト、アクセントは緑、角丸は大きめ。
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      error: AppColors.over,
      surface: AppColors.card,
    ).copyWith(
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.sub,
      outline: AppColors.faint,
      outlineVariant: AppColors.line,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );

  return base.copyWith(
    textTheme: GoogleFonts.mPlusRounded1cTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    dividerColor: AppColors.line,
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xF02A2723),
    ),
  );
}

/// ロゴ・見出し用の Zen Maru Gothic スタイル。
TextStyle brandTextStyle({
  double fontSize = 22,
  FontWeight fontWeight = FontWeight.w700,
  Color color = AppColors.ink,
  double? height,
}) =>
    GoogleFonts.zenMaruGothic(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
