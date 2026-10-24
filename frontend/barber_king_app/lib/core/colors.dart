import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFD6B25E);
  static const Color primaryLight = Color(0xFFF4DA9A);
  static const Color primaryDark = Color(0xFFA9832F);

  static const Color background = Color(0xFF070A12);
  static const Color backgroundSoft = Color(0xFF0B101C);
  static const Color card = Color(0xFF111824);
  static const Color surface = Color(0xFF172033);
  static const Color surfaceAlt = Color(0xFF1D2940);

  static const Color border = Color(0xFF26324A);
  static const Color borderStrong = Color(0xFF354563);

  static const Color white = Color(0xFFF8FAFC);
  static const Color subtitle = Color(0xFF94A3B8);
  static const Color muted = Color(0xFF64748B);

  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  static const Color black = Color(0xFF090C12);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF182338), card],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2C2412), Color(0xFF141B2A), Color(0xFF0E1420)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0C1220), background],
  );
}
