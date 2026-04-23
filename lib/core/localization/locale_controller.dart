import 'dart:ui';
import 'package:get/get.dart';
import '../../data/services/storage_service.dart';

/// Controls app locale and persists user preference.
/// Registered in InitialBinding as permanent.
class LocaleController extends GetxController {
  static const String _storageKey = 'app_locale';

  /// Current locale — observable for UI reactivity
  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;

  /// Supported locales list
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  /// Load persisted locale on startup
  void _loadSavedLocale() {
    final stored = StorageService.instance.read<String>(_storageKey);
    if (stored != null && stored.isNotEmpty) {
      final parts = stored.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        currentLocale.value = locale;
        Get.updateLocale(locale);
      }
    }
  }

  /// Switch to Arabic
  void switchToArabic() => changeLocale(const Locale('ar', 'SA'));

  /// Switch to English
  void switchToEnglish() => changeLocale(const Locale('en', 'US'));

  /// Toggle between English and Arabic
  void toggleLocale() {
    if (isArabic) {
      switchToEnglish();
    } else {
      switchToArabic();
    }
  }

  /// Change to any supported locale
  void changeLocale(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
    StorageService.instance.write(_storageKey, '${locale.languageCode}_${locale.countryCode}');
  }

  /// Convenience getters
  bool get isArabic => currentLocale.value.languageCode == 'ar';
  bool get isEnglish => currentLocale.value.languageCode == 'en';
  bool get isRTL => isArabic;
}
