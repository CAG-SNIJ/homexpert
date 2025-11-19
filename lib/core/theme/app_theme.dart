import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - HomeXpert Brand Colors
  static const Color primaryColor = Color(0xFF387366); // HomeXpert Green
  static const Color secondaryColor = Color(0xFF4A8B7A); // Lighter Green
  static const Color accentColor = Color(0xFF2D5A4E); // Darker Green
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF387366); // Same as primary
  static const Color warningColor = Color(0xFFFFC107);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),
      textTheme: TextTheme(
        // Poppins for large headings (32px, 28px, 24px)
        displayLarge: const TextStyle(
          fontFamily: 'Poppins',
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Poppins',
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: const TextStyle(
          fontFamily: 'Poppins',
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        // Poppins for medium headings (20px, 18px)
        headlineMedium: const TextStyle(
          fontFamily: 'Poppins',
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'Poppins',
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        // Roboto for body text (16px, 14px, 12px)
        bodyLarge: const TextStyle(
          fontFamily: 'Roboto',
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Roboto',
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        // Roboto for small descriptions (12px)
        bodySmall: const TextStyle(
          fontFamily: 'Roboto',
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelSmall: const TextStyle(
          fontFamily: 'Roboto',
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

