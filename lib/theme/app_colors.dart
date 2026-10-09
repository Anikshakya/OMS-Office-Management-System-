import 'package:flutter/material.dart';

/// Part of the day, used to pick the greeting and the hero-card gradient.
enum DayPart { morning, afternoon, evening, night }

extension DayPartX on DayPart {
  String get greeting {
    switch (this) {
      case DayPart.morning:
        return 'Good Morning';
      case DayPart.afternoon:
        return 'Good Afternoon';
      case DayPart.evening:
      case DayPart.night:
        return 'Good Evening';
    }
  }
}

/// A pastel background / foreground pair (used by shortcut tiles etc.).
class AppTone {
  final Color background;
  final Color foreground;

  const AppTone(this.background, this.foreground);
}

class AppColors {
  // ---------------------------------------------------------------------------
  // Primary Teal Theme
  // ---------------------------------------------------------------------------

  static const Color primary = Color(0xFF59C6C6);
  static const Color primaryLight = Color(0xFF91DEDE);
  static const Color primaryDark = Color(0xFF268F91);

  static const Color primaryContainer = Color(0xFFDDF5F4);

  static const Color secondary = Color(0xFF3B9E9E);
  static const Color secondaryLight = Color(0xFF78D2D0);

  // Semantic Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF59C6C6);

  // ---------------------------------------------------------------------------
  // Light Theme Palette
  // ---------------------------------------------------------------------------

  static const Color bgLight = Color(0xFFF5F9F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color glassLight = Color(0xD9FFFFFF);

  static const Color borderLight = Color(0x1F000000);

  static const Color textPrimaryLight = Color(0xFF182B2B);
  static const Color textSecondaryLight = Color(0xFF526666);
  static const Color textMutedLight = Color(0xFF849696);

  // ---------------------------------------------------------------------------
  // Dark Theme Palette
  // ---------------------------------------------------------------------------

  static const Color bgDark = Color(0xFF101818);
  static const Color surfaceDark = Color(0xFF1A2424);
  static const Color cardDark = Color(0xFF222F2F);
  static const Color glassDark = Color(0xB3222F2F);

  static const Color borderDark = Color(0x33FFFFFF);

  static const Color textPrimaryDark = Color(0xFFF2FAFA);
  static const Color textSecondaryDark = Color(0xFFB3C5C5);
  static const Color textMutedDark = Color(0xFF849696);

  // ---------------------------------------------------------------------------
  // Minimal UI: Surfaces, Dividers and Text
  // ---------------------------------------------------------------------------

  static const Color inkLight = Color(0xFF1C2B33);
  static const Color inkDark = Color(0xFFFFFFFF);

  static const Color dividerSoftLight = Color(0x14000000);
  static const Color dividerSoftDark = Color(0x1AFFFFFF);

  static const Color borderSoftLight = Color(0xFFDCE9E9);

  /// Surface used by cards / list containers.
  static Color surface(bool isDark) =>
      isDark ? surfaceDark : cardLight;

  static Color ink(bool isDark) =>
      isDark ? inkDark : inkLight;

  static Color dividerSoft(bool isDark) =>
      isDark ? dividerSoftDark : dividerSoftLight;

  // ---------------------------------------------------------------------------
  // Time of Day: Hero Card
  // ---------------------------------------------------------------------------

  /// 05:00-11:59 morning, 12:00-16:59 afternoon,
  /// 17:00-20:59 evening, 21:00-04:59 night.
  static DayPart dayPartFor(DateTime time) {
    final h = time.hour;

    if (h >= 5 && h < 12) return DayPart.morning;
    if (h >= 12 && h < 17) return DayPart.afternoon;
    if (h >= 17 && h < 21) return DayPart.evening;

    return DayPart.night;
  }

  static List<Color> heroGradient(DayPart part, bool isDark) {
    if (part == DayPart.night) {
      return const [
        Color(0xFF101C2C),
        Color(0xFF192C40),
        Color(0xFF20394A),
      ];
    }

    if (isDark) {
      // Muted, deep teal for daytime in dark mode.
      return const [
        Color(0xFF173536),
        Color(0xFF204747),
        Color(0xFF285656),
      ];
    }

    // Fresh, light teal for daytime in light mode.
    return const [
      Color(0xFFDDF5F4),
      Color(0xFFBCEAE7),
      Color(0xFF91DEDE),
    ];
  }

  /// Colour of the sun or moon.
  static Color heroSun(DayPart part, bool isDark) {
    switch (part) {
      case DayPart.morning:
        return isDark
            ? const Color(0xFFE6C77A)
            : const Color(0xFFFFD66B);

      case DayPart.afternoon:
        return isDark
            ? const Color(0xFFF0D68A)
            : const Color(0xFFFFE699);

      case DayPart.evening:
        return isDark
            ? const Color(0xFFFFB89D)
            : const Color(0xFFFFAA8A);

      case DayPart.night:
        return isDark
            ? const Color(0xFFE2E8F0)
            : const Color(0xFFF1F5F9);
    }
  }

  // ---------------------------------------------------------------------------
  // Pastel Tones: Shortcut Tiles
  // ---------------------------------------------------------------------------

  static AppTone toneYellow(bool isDark) => isDark
      ? const AppTone(
          Color(0x29F0C75A),
          Color(0xFFF2D68A),
        )
      : const AppTone(
          Color(0xFFF7E8B5),
          Color(0xFF7A5F12),
        );

  static AppTone toneRose(bool isDark) => isDark
      ? const AppTone(
          Color(0x29F08C78),
          Color(0xFFF4B2A4),
        )
      : const AppTone(
          Color(0xFFF6D5CB),
          Color(0xFF8A3F2E),
        );

  static AppTone toneMint(bool isDark) => isDark
      ? const AppTone(
          Color(0x2959C6C6),
          Color(0xFF91DEDE),
        )
      : const AppTone(
          Color(0xFFDDF5F4),
          Color(0xFF267F80),
        );

  // ---------------------------------------------------------------------------
  // Shadows
  // ---------------------------------------------------------------------------

  static List<BoxShadow> softShadow(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(
          alpha: isDark ? 0.25 : 0.04,
        ),
        blurRadius: 12,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> hoverShadow(bool isDark) {
    return [
      BoxShadow(
        color: primary.withValues(
          alpha: isDark ? 0.22 : 0.16,
        ),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
