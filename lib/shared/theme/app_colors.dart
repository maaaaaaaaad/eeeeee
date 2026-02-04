import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color pastelPink = Color(0xFFFFB5BA);
  static const Color accentPink = Color(0xFFFF8A94);
  static const Color lightPink = Color(0xFFFFE4E6);
  static const Color softPink = Color(0xFFFFD1D5);
  static const Color darkPink = Color(0xFFD4848A);

  static const Color primary = pastelPink;
  static const Color primaryLight = lightPink;
  static const Color primaryDark = darkPink;

  static const Color lavenderLight = Color(0xFFE8E0F0);
  static const Color lavenderDark = Color(0xFFB8A9E8);

  static const Color background = Color(0xFFF8F8F8);
  static const Color backgroundLight = Color(0xFFF8F8F8);
  static const Color backgroundMedium = Color(0xFFEFEFEF);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  static Color glassWhite = Colors.white.withValues(alpha: 0.6);
  static Color glassBorder = Colors.white.withValues(alpha: 0.3);

  static const Color error = Color(0xFFB00020);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
}
