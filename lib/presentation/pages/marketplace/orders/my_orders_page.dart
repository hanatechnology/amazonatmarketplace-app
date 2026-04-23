import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/localization/locale_keys.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(LocaleKeys.myOrders.tr),
      ),
    );
  }
}
