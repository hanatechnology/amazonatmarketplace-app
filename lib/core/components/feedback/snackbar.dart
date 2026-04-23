import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, warning, info }

/// Application-wide snackbar helper using GetX.
class AppSnackbar {
  AppSnackbar._();

  static void show({
    required String message,
    required SnackbarType type,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (icon, bg, fg) = switch (type) {
      SnackbarType.success => (
          Icons.check_circle_outline_rounded,
          const Color(0xFF2E7D32),
          Colors.white,
        ),
      SnackbarType.error => (
          Icons.error_outline_rounded,
          const Color(0xFFB00020),
          Colors.white,
        ),
      SnackbarType.warning => (
          Icons.warning_amber_rounded,
          const Color(0xFFE65100),
          Colors.white,
        ),
      SnackbarType.info => (
          Icons.info_outline_rounded,
          const Color(0xFF0277BD),
          Colors.white,
        ),
    };

    Get.snackbar(
      title ?? _defaultTitle(type),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bg,
      colorText: fg,
      icon: Icon(icon, color: fg),
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  static void success(String message, {String? title}) =>
      show(message: message, type: SnackbarType.success, title: title);

  static void error(String message, {String? title}) =>
      show(message: message, type: SnackbarType.error, title: title);

  static void warning(String message, {String? title}) =>
      show(message: message, type: SnackbarType.warning, title: title);

  static void info(String message, {String? title}) =>
      show(message: message, type: SnackbarType.info, title: title);

  static String _defaultTitle(SnackbarType type) => switch (type) {
        SnackbarType.success => 'Success',
        SnackbarType.error => 'Error',
        SnackbarType.warning => 'Warning',
        SnackbarType.info => 'Info',
      };
}
