import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/checkout/order_outcome_view.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../domain/entities/marketplace/checkout_args.dart';
import '../../../controllers/marketplace/main_navigation_controller.dart';

/// The payment did not complete.
///
/// Nothing was charged, and this store's items are still in the cart — the
/// cart is only cleared for a store once its order is actually placed — so the
/// recovery is the cart, not a second checkout.
class OrderCancelledPage extends StatelessWidget {
  const OrderCancelledPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as OrderCancelledArgs?;

    return OrderOutcomeView(
      isSuccess: false,
      title: LocaleKeys.paymentCancelled.tr,
      lead: LocaleKeys.paymentCancelledMessage.tr,
      orderNumber: args?.orderNumber,
      orderNumberLabel: LocaleKeys.orderNumber.tr,
      statusLabel: LocaleKeys.statusLabel.tr,
      statusValue: LocaleKeys.statusCancelled.tr,
      amountLabel: LocaleKeys.amountLabel.tr,
      amount: args?.total,
      primaryLabel: LocaleKeys.backToCart.tr,
      onPrimary: () => Get.offAllNamed(
        Routes.MARKETPLACE_MAIN,
        arguments: {'tab': MainNavigationController.cartTab},
      ),
      ghostLabel: LocaleKeys.continueShopping.tr,
      onGhost: () => Get.offAllNamed(Routes.MARKETPLACE_MAIN),
    );
  }
}
