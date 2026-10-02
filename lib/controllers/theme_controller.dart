import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/services/theme_service.dart';

class ThemeController extends GetxController {
  ThemeController({ThemeService? themeService})
    : _themeService = themeService ?? ThemeService();

  final ThemeService _themeService;
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _themeService.loadThemeMode();
  }

  void toggleTheme() {
    setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _themeService.saveThemeMode(mode);
  }
}
