import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF072252);
  static const Color primaryBlue = Color(0xFF0A2A67);
  static const Color accentGold = Color(0xFFF3B52F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentGold,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE3E6EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE3E6EA)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: primaryBlue,
        indicatorColor: Colors.white24,
        elevation: 0,
        height: 65,
        labelTextStyle: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12);
          }
          return const TextStyle(color: Colors.white70, fontSize: 12);
        }),
        iconTheme: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: Colors.white, size: 26);
          }
          return const IconThemeData(color: Colors.white70, size: 24);
        }),
      ),
    );
  }
}
