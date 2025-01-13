import 'package:flutter/material.dart';

class AppTheme {
  // Define primary colors for the sports theme
  static const Color primaryColor = Color(0xFF1A73E8); // Vibrant Blue
  static const Color secondaryColor = Color(0xFF34A853); // Energetic Green
  static const Color accentColor = Color(0xFFFFA726); // Bright Orange
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const Color cardColor = Color(0xFFFFFFFF); // White
  static const Color textColor = Color(0xFF212121); // Dark Gray

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: accentColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
      titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: const TextStyle(fontSize: 16, color: textColor),
      bodyMedium:  TextStyle(fontSize: 14, color: Colors.grey[800]),
    ),
    // iconTheme: const IconThemeData(color: Colors.black12, size: 24),
  );
}
