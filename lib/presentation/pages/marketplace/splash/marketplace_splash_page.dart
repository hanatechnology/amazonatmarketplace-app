import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/network/dio_client.dart';
import 'package:marketplace/data/services/push_notification_service.dart';
import 'package:marketplace/data/services/storage_service.dart';

class MarketplaceSplashPage extends StatefulWidget {
  const MarketplaceSplashPage({super.key});

  @override
  State<MarketplaceSplashPage> createState() => _MarketplaceSplashPageState();
}

class _MarketplaceSplashPageState extends State<MarketplaceSplashPage> {
  @override
  void initState() {
    super.initState();
    _routeOnStartup();
  }

  /// A stored JWT means the customer is still signed in — the token is good for
  /// seven days — so skip the login screen entirely. `offAllNamed` keeps the
  /// splash out of the back stack either way.
  Future<void> _routeOnStartup() async {
    final results = await Future.wait([
      StorageService.instance.getToken(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    final token = results.first as String?;

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Get.find<DioClient>().updateToken(token);
      // Restored session: re-send the token, which may have rotated while the
      // app was closed, and route any notification the app was launched from.
      PushNotificationService.instance.registerForCurrentUser();
      Get.offAllNamed(Routes.MARKETPLACE_MAIN);
      PushNotificationService.instance.handleLaunchMessage();
    } else {
      Get.offAllNamed(Routes.MARKETPLACE_LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(LocaleKeys.appName.tr),
      ),
    );
  }
}
