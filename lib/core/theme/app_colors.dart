import 'package:flutter/material.dart';

/// つかいきり デザイントークン（Claude Design 由来の配色）。
///
/// 値は `shared.jsx` の `T` を Flutter の [Color] に写したもの。
/// 温かみのあるオフホワイト＋フレッシュな緑＋期限ステータス3色が基本。
abstract final class AppColors {
  // ベース面・文字
  static const bg = Color(0xFFF7F5F0); // 画面背景（オフホワイト）
  static const card = Color(0xFFFFFFFF); // カード白
  static const ink = Color(0xFF2A2723); // 主要文字（暖かい黒）
  static const sub = Color(0xFF8C877C); // 補助文字
  static const faint = Color(0xFFB8B2A6); // さらに控えめな文字
  static const line = Color(0xFFEDE9E1); // 区切り線

  // アクセント緑
  static const green = Color(0xFF1F7A55);
  static const greenInk = Color(0xFF15613F);
  static const greenSoft = Color(0xFFE8F3EC);

  // 期限ステータス：余裕（控えめグレー）
  static const plenty = Color(0xFFA8A296);
  static const plentySoft = Color(0xFFF0EEE7);

  // 期限ステータス：近い（オレンジ）
  static const near = Color(0xFFE0892F);
  static const nearSoft = Color(0xFFFBEBD8);

  // 期限ステータス：超過（赤）
  static const over = Color(0xFFD14B3D);
  static const overSoft = Color(0xFFF8E2DD);

  // Buy Me a Coffee ブランド色
  static const coffee = Color(0xFFFFDD00);
  static const coffeeSoft = Color(0xFFF6ECD6);
}
