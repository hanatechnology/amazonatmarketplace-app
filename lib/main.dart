import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/services/storage_service.dart';
import 'core/network/dio_client.dart';
import 'core/theme/marketplace_theme.dart';
import 'core/localization/app_translations.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
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

      // ── Translation setup ──────────────────────────────
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),       // Default locale
      fallbackLocale: const Locale('en', 'US'), // Fallback if key missing

      initialRoute: Routes.MARKETPLACE,
      initialBinding: InitialBinding(),
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
