import 'package:flutter/material.dart';

class AyuTheme {
  static const Color primaryTeal = Color(0xFF00a8cc);
  static const Color lightTeal = Color(0xFFa8edea);
  static const Color lightPink = Color(0xFFfed6e3);
  static const Color darkBlue = Color(0xFF1a5f7a);
  static const Color textDark = Color(0xFF2d3748);
  static const Color textGray = Color(0xFF718096);

  static const Color sectionBarColor = Color(0xFF00b7d4);
  
  static LinearGradient headerGradient = const LinearGradient(
    colors: [Color(0xFF00d4ff), Color(0xFF00a8cc)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heroGradient = const LinearGradient(
    colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryTeal,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: darkBlue,
      ),
      fontFamily: 'Roboto', // Modern enough
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
