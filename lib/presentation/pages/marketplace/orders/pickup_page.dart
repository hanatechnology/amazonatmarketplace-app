import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/localization/locale_keys.dart';

class PickupPage extends StatelessWidget {
  const PickupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(LocaleKeys.pickup.tr),
      ),
    );
  }
}
