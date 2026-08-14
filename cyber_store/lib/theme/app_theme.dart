import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Palette ─────────────────────────────────────────────────────────
  static const Color black      = Color(0xFF000000);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color grey100    = Color(0xFFF5F5F5);
  static const Color grey200    = Color(0xFFEEEEEE);
  static const Color grey400    = Color(0xFFBDBDBD);
  static const Color grey600    = Color(0xFF757575);
  static const Color grey800    = Color(0xFF424242);
  static const Color dark       = Color(0xFF1A1A1A);
  static const Color darkCard   = Color(0xFF242424);
  static const Color accent     = Color(0xFFFFD700); // star / badge gold

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: black,
      brightness: Brightness.light,
      primary: black,
      onPrimary: white,
      secondary: grey800,
      surface: white,
      background: white,
    ),
    scaffoldBackgroundColor: white,
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: black,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: black,
        letterSpacing: -0.5,
      ),
    ),
    textTheme: _textTheme(black),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: black,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: black, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: grey200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: grey200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: black, width: 1.5),
      ),
      hintStyle: const TextStyle(color: grey400, fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(color: grey200, thickness: 1),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected) ? black : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected) ? black : grey400),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: grey100,
      selectedColor: black,
      labelStyle: const TextStyle(fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: black,
      unselectedItemColor: grey400,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // ── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: white,
      brightness: Brightness.dark,
      primary: white,
      onPrimary: black,
      surface: dark,
    ),
    scaffoldBackgroundColor: black,
    textTheme: _textTheme(white),
  );

  // ── Midnight Blue Theme ──────────────────────────────────────────────────
  static ThemeData get midnightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1),
      brightness: Brightness.dark,
      primary: const Color(0xFF42A5F5),
      surface: const Color(0xFF001529),
    ),
    scaffoldBackgroundColor: const Color(0xFF000B1A),
    textTheme: _textTheme(white),
  );

  // ── Forest Green Theme ───────────────────────────────────────────────────
  static ThemeData get forestTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B5E20),
      brightness: Brightness.dark,
      primary: const Color(0xFF81C784),
      surface: const Color(0xFF0A1F0A),
    ),
    scaffoldBackgroundColor: const Color(0xFF050F05),
    textTheme: _textTheme(white),
  );

  // ── Sunset Orange Theme ──────────────────────────────────────────────────
  static ThemeData get sunsetTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF6F00),
      primary: const Color(0xFFFF8F00),
      surface: const Color(0xFFFFF3E0),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    textTheme: _textTheme(black),
  );

  static TextTheme _textTheme(Color base) => TextTheme(
    displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: base),
    displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: base),
    displaySmall:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: base),
    headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: base),
    headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: base),
    headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: base),
    titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: base),
    titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: base),
    titleSmall:    TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: base),
    bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: base),
    bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: base),
    bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: grey600),
    labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: base),
    labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: base),
    labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: grey600),
  );
}
