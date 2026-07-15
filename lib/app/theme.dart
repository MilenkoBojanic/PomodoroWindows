import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0D1B12);
  static const surface = Color(0xFF1A2E23);
  static const surfaceLight = Color(0xFF243B2E);
  static const accent = Color(0xFF4CAF50);
  static const accentBright = Color(0xFF81C784);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFB0BEC5);
  static const active = Color(0xFF2E7D32);
  static const upcoming = Color(0xFF1565C0);
  static const completed = Color(0xFF455A64);
}

ThemeData buildDisplayTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: AppColors.textSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    ),
  );
}
