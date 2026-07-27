import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpod provider for dynamic theme switching
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class AppTheme {
  // Premium Colors
  static const Color primaryOrange = Color(0xFFFF6B00); // Spicy Orange
  static const Color statusGreen = Color(0xFF22C55E);    // Emerald Green
  static const Color ratingYellow = Color(0xFFF5B301);   // Deep Yellow
  static const Color dangerRed = Color(0xFFDC4C4C);      // Muted Red

  // Light Theme Colors
  static const Color lightBg = Color(0xFFFFF8F0);        // Warm Cream
  static const Color lightTextDark = Color(0xFF2B2B2B);  // Warm Charcoal
  static const Color lightTextMuted = Color(0xFF6B6B6B);
  static const Color lightCard = Colors.white;

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextLight = Color(0xFFF5F5F5);
  static const Color darkTextMuted = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: Color(0xFF5D4037), // Earthy Brown
        background: lightBg,
        surface: lightCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: lightTextDark,
        onSurface: lightTextDark,
        error: dangerRed,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: lightTextDark, fontFamily: 'sans-serif'),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightTextDark),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextDark),
        bodyLarge: TextStyle(fontSize: 16, color: lightTextDark, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, color: lightTextMuted, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryOrange),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF5D4037),
          side: const BorderSide(color: Color(0xFF5D4037), width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withOpacity(0.04),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.dark,
        primary: primaryOrange,
        secondary: Color(0xFF8D6E63), // Light Earthy Brown
        background: darkBg,
        surface: darkCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: darkTextLight,
        onSurface: darkTextLight,
        error: dangerRed,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkTextLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextLight,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: darkTextLight),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkTextLight),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextLight),
        bodyLarge: TextStyle(fontSize: 16, color: darkTextLight, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, color: darkTextMuted, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryOrange),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextLight,
          side: const BorderSide(color: darkTextLight, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}
