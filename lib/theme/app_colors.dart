import 'package:flutter/material.dart';

class AppColors {
  // iOS Inspired System Accent Colors
  static const Color primary = Color.fromARGB(255, 131, 79, 255); // iOS System Blue
  static const Color primaryLight = Color.fromARGB(255, 185, 147, 255);
  static const Color primaryDark = Color.fromARGB(255, 119, 1, 255);
  static const Color primaryContainer = Color(0xFFE5F1FF);

  static const Color secondary = Color(0xFF5E5CE6); // iOS System Indigo
  static const Color secondaryLight = Color(0xFF7D7AFF);

  // Semantic Status Colors (iOS Palette)
  static const Color success = Color(0xFF34C759); // iOS System Green
  static const Color warning = Color(0xFFFF9500); // iOS System Orange
  static const Color error = Color.fromARGB(72, 255, 58, 48); // iOS System Red
  static const Color info = Color(0xFF64D2FF); // iOS System Cyan

  // Light Theme Palette (iOS 18 Light)
  static const Color bgLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color glassLight = Color(0xD9FFFFFF); // 85% opacity
  static const Color borderLight = Color(0x1F000000); // 12% black border
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF3C3C43);
  static const Color textMutedLight = Color(0xFF8E8E93);

  // Dark Theme Palette (iOS 18 Dark)
  static const Color bgDark = Color(0xFF000000); // True iOS Dark
  static const Color surfaceDark = Color(0xFF1C1C1E); // iOS Card Dark
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color glassDark = Color(0xB32C2C2E);
  static const Color borderDark = Color(0x33FFFFFF); // Subtle white border
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0x99FFFFFF);
  static const Color textMutedDark = Color(0xFF8E8E93);

  static List<BoxShadow> softShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> hoverShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? primary.withValues(alpha: 0.3) : primary.withValues(alpha: 0.15),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
