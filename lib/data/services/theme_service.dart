import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'storage_service.dart';

/// Owns the app's light/dark preference and persists it.
///
/// Default is [ThemeMode.system] — the app follows the device until the
/// customer picks a mode explicitly.
class ThemeService extends GetxService {
  static const String _storageKey = 'app_theme_mode';

  final Rx<ThemeMode> mode = ThemeMode.system.obs;

  /// Read straight from storage, before GetX is wired up, so
  /// `GetMaterialApp.themeMode` starts on the right value with no flash.
  static ThemeMode get storedMode =>
      _parse(StorageService.instance.read<String>(_storageKey));

  @override
  void onInit() {
    super.onInit();
    mode.value = storedMode;
  }

  bool get isDark =>
      mode.value == ThemeMode.dark ||
      (mode.value == ThemeMode.system &&
          Get.mediaQuery.platformBrightness == Brightness.dark);

  void setMode(ThemeMode next) {
    if (mode.value == next) return;
    mode.value = next;
    StorageService.instance.write(_storageKey, next.name);
    Get.changeThemeMode(next);
  }

  /// Light ⇄ dark. From [ThemeMode.system] it jumps to the opposite of what
  /// the device is currently showing, which is what a customer tapping a
  /// toggle expects.
  void toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);

  static ThemeMode _parse(String? stored) {
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
