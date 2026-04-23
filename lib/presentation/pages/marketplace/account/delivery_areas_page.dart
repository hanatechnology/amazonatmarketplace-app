import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/localization/locale_keys.dart';

class DeliveryAreasPage extends StatelessWidget {
  const DeliveryAreasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(LocaleKeys.deliveryAreas.tr),
      ),
    );
  }
}
