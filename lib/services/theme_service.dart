import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  ThemeService({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const _themeModeKey = 'themeMode';
  final GetStorage _storage;

  ThemeMode loadThemeMode() {
    return _storage.read<String>(_themeModeKey) == 'light'
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.write(
      _themeModeKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }
}
