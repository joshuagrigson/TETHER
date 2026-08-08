import 'package:flutter/material.dart';

abstract final class TetherColors {
  static const obsidian = Color(0xFF07080B);
  static const midnight = Color(0xFF0D1118);
  static const surface = Color(0xFF141923);
  static const surfaceRaised = Color(0xFF1B2230);
  static const line = Color(0xFF2A3342);
  static const text = Color(0xFFF3F5F8);
  static const muted = Color(0xFF8D98AA);
  static const neon = Color(0xFF73F7D4);
  static const violet = Color(0xFF9B8CFF);
  static const danger = Color(0xFFFF6F91);
}

abstract final class TetherTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: TetherColors.neon,
      brightness: Brightness.dark,
      surface: TetherColors.surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        surface: TetherColors.surface,
        onSurface: TetherColors.text,
      ),
      scaffoldBackgroundColor: TetherColors.obsidian,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: TetherColors.text,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: TetherColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
