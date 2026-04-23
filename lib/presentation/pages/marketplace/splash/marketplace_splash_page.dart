import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/localization/locale_keys.dart';

class MarketplaceSplashPage extends StatefulWidget {
  const MarketplaceSplashPage({super.key});

  @override
  State<MarketplaceSplashPage> createState() => _MarketplaceSplashPageState();
}

class _MarketplaceSplashPageState extends State<MarketplaceSplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Get.toNamed(Routes.MARKETPLACE_LOGIN);
    });
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
