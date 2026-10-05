import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/toast_notification.dart' show ToastType;
import '../theme/app_colors.dart';

/// Centralized Toast Notification service allowing flexible UI feedback.
class ToastService {
  ToastService._internal();

  /// Displays a customizable toast message.
  static void showToast({
    required String message,
    String title = '',
    String? headingMessage,
    bool? isSuccess,
    bool? isEn,
    Duration? duration,
    Color? backgroundColor,
    Color textColor = Colors.black,
    IconData? icon,
    Color? accentColor,
  }) {
    if (message.isEmpty || Get.key.currentState == null) return;

    final heading = headingMessage ?? (title.isEmpty ? null : title);
    final succeeded = isSuccess ?? icon == Icons.check_circle_rounded;
    final statusColor =
        accentColor ?? (succeeded ? AppColors.success : AppColors.error);
    final surfaceColor =
        backgroundColor ??
        (Get.isDarkMode ? const Color(0xFF242426) : const Color(0xFFFCFCFD));
    final foregroundColor = Get.isDarkMode ? Colors.white : textColor;

    Get.showSnackbar(
      GetSnackBar(
        title: '',
        message: '',
        titleText: Padding(
          padding: EdgeInsets.only(top: isEn == true ? 1 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ??
                      (succeeded
                          ? Icons.check_rounded
                          : Icons.info_outline_rounded),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (heading != null) ...[
                      Text(
                        heading,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: TextStyle(
                        color: foregroundColor.withValues(
                          alpha: heading == null ? 1 : 0.76,
                        ),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        messageText: const SizedBox.shrink(),
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        duration: duration ?? Duration(seconds: heading == null ? 3 : 5),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: surfaceColor,
        borderColor: statusColor.withValues(alpha: 0.28),
        borderWidth: 1,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Get.isDarkMode ? 0.24 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static void showAppToast(String title, String message, ToastType type) {
    final (color, icon) = switch (type) {
      ToastType.success => (AppColors.success, Icons.check_circle_rounded),
      ToastType.error => (AppColors.error, Icons.error_outline_rounded),
      ToastType.warning => (AppColors.warning, Icons.warning_amber_rounded),
      ToastType.info => (AppColors.primary, Icons.info_outline_rounded),
    };

    showToast(
      title: title,
      message: message,
      isSuccess: type == ToastType.success,
      icon: icon,
      accentColor: color,
    );
  }

  /// Helper for displaying success notifications.
  static void showSuccessToast(String message) {
    showToast(message: message, isSuccess: true);
  }

  /// Helper for displaying error notifications.
  static void showErrorToast(String message) {
    showToast(message: message, isSuccess: false);
  }
}
