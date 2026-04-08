import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      height: 1.05,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      height: 1.1,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      color: AppColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      height: 1.15,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.55,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.45,
      fontWeight: FontWeight.w500,
      color: AppColors.outline,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
      color: AppColors.outline,
    ),
  );
}
