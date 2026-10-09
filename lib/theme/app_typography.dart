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

  // ---------------------------------------------------------------------------
  // Minimal-UI additions
  // ---------------------------------------------------------------------------

  /// Small greeting line on the hero card ("Good Morning,").
  static TextStyle heroGreeting(Color color) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color.withValues(alpha: 0.72),
        height: 1.2,
      );

  /// Large user name on the hero card.
  static TextStyle heroName(Color color) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
        height: 1.15,
      );

  /// Designation line on the hero card.
  static TextStyle heroMeta(Color color) => TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: color.withValues(alpha: 0.72),
        height: 1.2,
      );

  /// Department chip on the hero card.
  static TextStyle heroChip(Color color) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: color,
      );

  /// Label inside pill buttons.
  static TextStyle pillLabel(Color color) => TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.1,
      );

  /// Section card title ("Employees On Leave").
  static TextStyle sectionTitle(bool isDark) => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.25,
      );

  /// Accent action text ("Today", "Reset to Today").
  static TextStyle sectionAction(bool isDark) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.primaryLight : AppColors.primary,
        height: 1.2,
      );

  /// Shortcut tile label.
  static TextStyle tileLabel(Color color) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.2,
      );

  /// Primary text of a list row.
  static TextStyle listTitle(bool isDark) => TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.25,
      );

  /// Secondary text of a list row.
  static TextStyle listMeta(bool isDark) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        height: 1.3,
      );
}