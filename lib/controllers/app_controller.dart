import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oms/state/app_state.dart' show ToastNotification, ToastType;

class AppController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;
  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  final RxInt selectedPageIndex = 0.obs;

  final RxList<ToastNotification> toasts = <ToastNotification>[].obs;

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  void setPageIndex(int index) {
    selectedPageIndex.value = index;
  }

  void showToast(String title, String message, ToastType type) {
    final toast = ToastNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
    );
    toasts.add(toast);

    Future.delayed(const Duration(seconds: 4), () {
      toasts.removeWhere((t) => t.id == toast.id);
    });
  }

  void dismissToast(String id) {
    toasts.removeWhere((t) => t.id == id);
  }
}
