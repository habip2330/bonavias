import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFFBC8157);
  static const secondaryColor = Color(0xFFD7A86E);
  static const backgroundColor = Color(0xFFF8E9E0);
  static const cardColor = Color(0xFFFFF3E0);
  static const errorColor = Color(0xFFDC2626);
  static const textColor = Color(0xFF3E2723);
  static const secondaryTextColor = Color(0xFF8D6E63);
  static const successColor = Color(0xFF8D9440);
  static const seedColor = Color(0xFFBC8157);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFB8835A),
        onPrimary: Colors.white,
        secondary: Color(0xFFF5CBA7),
        onSecondary: Color(0xFF3E2723),
        background: Color(0xFFF8E9E0),
        onBackground: Color(0xFF3E2723),
        surface: Colors.white,
        onSurface: Color(0xFF5D4037),
        error: Color(0xFFDC2626),
        onError: Colors.white,
        outline: Color(0xFFE0C3A3),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFB8835A),
        onPrimary: Colors.white,
        secondary: Color(0xFFF5CBA7),
        onSecondary: Color(0xFF3E2723),
        background: Color(0xFF23201A),
        onBackground: Color(0xFFF5CBA7),
        surface: Color(0xFF2C2620),
        onSurface: Color(0xFFF5CBA7),
        error: Color(0xFFDC2626),
        onError: Colors.white,
        outline: Color(0xFFB8835A),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
} 