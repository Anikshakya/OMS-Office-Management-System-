import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/toast_notification.dart' show ToastType;

/// Centralized Toast Notification service allowing flexible UI feedback.
class ToastService {
  ToastService._internal();

  /// Displays a customizable toast message.
  static void showToast({
    required String message,
    String title = '',
    Duration duration = const Duration(seconds: 4),
    Color backgroundColor = const Color(0xFF1E293B),
    Color textColor = Colors.white,
    IconData? icon,
  }) {
    if (message.isEmpty || Get.key.currentState == null) return;

    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        icon: icon == null ? null : Icon(icon, color: textColor),
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        duration: duration,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: backgroundColor,
        borderRadius: 14,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static void showAppToast(String title, String message, ToastType type) {
    final (color, icon) = switch (type) {
      ToastType.success => (
        const Color(0xFF16A34A),
        Icons.check_circle_rounded,
      ),
      ToastType.error => (const Color(0xFFDC2626), Icons.error_rounded),
      ToastType.warning => (const Color(0xFFFF9500), Icons.warning_rounded),
      ToastType.info => (const Color(0xFF2563EB), Icons.info_rounded),
    };

    showToast(
      title: title,
      message: message,
      backgroundColor: color,
      icon: icon,
    );
  }

  /// Helper for displaying success notifications.
  static void showSuccessToast(String message) {
    showToast(
      message: message,
      backgroundColor: const Color(0xFF16A34A),
      textColor: Colors.white,
    );
  }

  /// Helper for displaying error notifications.
  static void showErrorToast(String message) {
    showToast(
      message: message,
      backgroundColor: const Color(0xFFDC2626),
      textColor: Colors.white,
    );
  }
}
