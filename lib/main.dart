import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/config/app_config.dart';
import 'data/services/push_notification_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/theme_service.dart';
import 'core/theme/marketplace_theme.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/locale_controller.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_router.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  // Version footer on the account page. A platform channel failure must not
  // stop the app from opening — the footer simply renders nothing.
  try {
    final info = await PackageInfo.fromPlatform();
    AppConfig.setPackageInfo(
      version: info.version,
      build: info.buildNumber,
    );
  } catch (_) {}
  // Registers the background handler and stream listeners. Never throws — a
  // Firebase problem must not stop the app from opening.
  await PushNotificationService.instance.init();
  runApp(const MarketplaceApp());
}

class MarketplaceApp extends StatelessWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Marketplace',
      debugShowCheckedModeBanner: false,
      theme: MarketplaceTheme.lightTheme,
      darkTheme: MarketplaceTheme.darkTheme,
      // Persisted preference, read synchronously so the first frame is already
      // in the right mode. Defaults to following the device.
      themeMode: ThemeService.storedMode,

      // ── Translation setup ──────────────────────────────
      translations: AppTranslations(),
      // Persisted, like themeMode above: a const here is re-applied on every
      // rebuild and drops the app back to English.
      locale: LocaleController.storedLocale,
      fallbackLocale: const Locale('en', 'US'), // Fallback if key missing

      initialRoute: Routes.MARKETPLACE,
      initialBinding: InitialBinding(),
      // Feeds AppRouter the live stack so a screen that is already open cannot
      // be pushed a second time. GetX merges this with its own observer.
      navigatorObservers: [AppRouteObserver.instance],
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      smartManagement: SmartManagement.full,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const _NotFoundPage(),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Text('404 - Page not found'),
      ),
    );
  }
}
