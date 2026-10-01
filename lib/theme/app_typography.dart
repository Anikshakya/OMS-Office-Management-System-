import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle displayLarge(bool isDark) => TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.2,
      );

  static TextStyle displayMedium(bool isDark) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.25,
      );

  static TextStyle titleLarge(bool isDark) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.3,
      );

  static TextStyle titleMedium(bool isDark) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.3,
      );

  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.4,
      );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        height: 1.35,
      );

  static TextStyle labelLarge(bool isDark) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.2,
      );

  static TextStyle labelMedium(bool isDark) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        height: 1.2,
      );

  static TextStyle caption(bool isDark) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        height: 1.2,
      );
}
