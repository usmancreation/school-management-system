import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primary = Color(0xFF1E3A8A); // Deep Royal Navy
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF0D9488); // Modern Teal
  static const Color accent = Color(0xFFF59E0B); // Amber accent
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF97316);
  static const Color error = Color(0xFFEF4444);

  // Backgrounds & Surfaces
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        error: error,
      ),
      scaffoldBackgroundColor: bgLight,
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        secondary: secondary,
        surface: surfaceDark,
        error: error,
      ),
      scaffoldBackgroundColor: bgDark,
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
      ),
    );
  }
}
