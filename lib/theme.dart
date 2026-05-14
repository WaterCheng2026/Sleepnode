import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2B5EA7);
  static const Color primaryLight = Color(0xFFE6F1FB);
  static const Color primaryMid = Color(0xFFB5D4F4);
  static const Color primaryDark = Color(0xFF0C447C);

  static const Color greenBg = Color(0xFFEAF3DE);
  static const Color greenText = Color(0xFF3B6D11);
  static const Color amberBg = Color(0xFFFAEEDA);
  static const Color amberText = Color(0xFF854F0B);

  static const Color success = Color(0xFF16A085);
  static const Color bgSecondary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);

  static const Color white = Colors.white;
  static const Color border = Color(0xFFE0E0E0);
}

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.bgSecondary,
    ),
    scaffoldBackgroundColor: AppColors.bgSecondary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
    ),
    useMaterial3: true,
  );
}
