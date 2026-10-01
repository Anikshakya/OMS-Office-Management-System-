import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Centralized Toast Notification service allowing flexible UI feedback.
class ToastService {
  ToastService._internal();

  /// Displays a customizable toast message.
  static void showToast({
    required String message,
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor = const Color(0xFF1E293B),
    Color textColor = Colors.white,
    double fontSize = 14.0,
  }) {
    if (message.isEmpty) return;

    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: 2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
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
