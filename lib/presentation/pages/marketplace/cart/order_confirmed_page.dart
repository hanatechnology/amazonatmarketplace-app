import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/checkout/order_outcome_view.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../domain/entities/marketplace/checkout_args.dart';
import 'package:marketplace/app/routes/app_router.dart';

/// The order exists and this store's items have left the cart.
///
/// Whether money has actually moved depends on the method — cash on delivery
/// has not been paid at all — so the receipt states the method rather than
/// asserting a payment.
class OrderConfirmedPage extends StatelessWidget {
  const OrderConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as OrderConfirmedArgs?;

    return OrderOutcomeView(
      isSuccess: true,
      title: LocaleKeys.orderConfirmed.tr,
      lead: LocaleKeys.orderConfirmedMessage.tr,
      orderNumber: args?.orderNumber,
      orderNumberLabel: LocaleKeys.orderNumber.tr,
      statusLabel: LocaleKeys.paymentMethod.tr,
      statusValue: args?.paymentMethod ?? '',
      amountLabel: LocaleKeys.amountPaid.tr,
      amount: args?.total,
      primaryLabel: LocaleKeys.trackMyOrder.tr,
      // The shell is restored first, then the order list pushed on top of it.
      // Sending the customer straight to the list with offAllNamed left it as
      // the only route on the stack: back had nothing to pop to and the screen
      // became a dead end.
      onPrimary: () {
        Get.offAllNamed(Routes.MARKETPLACE_MAIN);
        AppRouter.toNamed(Routes.MARKETPLACE_ORDERS);
      },
      ghostLabel: LocaleKeys.continueShopping.tr,
      onGhost: () => Get.offAllNamed(Routes.MARKETPLACE_MAIN),
    );
  }
}
