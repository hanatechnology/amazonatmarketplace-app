import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../localization/locale_keys.dart';
import 'checkout_section_header.dart';
import 'checkout_payment_card.dart';

class CheckoutPaymentSectionDto {
  const CheckoutPaymentSectionDto({
    required this.selectedMethod,
    required this.onSelect,
    this.hasError = false,
  });

  final CheckoutPaymentMethod? selectedMethod;
  final ValueChanged<CheckoutPaymentMethod> onSelect;
  final bool hasError;
}

/// Payment method selection section with all 5 options in spec order.
class CheckoutPaymentSection extends StatelessWidget {
  const CheckoutPaymentSection({super.key, required this.data});

  final CheckoutPaymentSectionDto data;

  static const _order = [
    CheckoutPaymentMethod.payOnDelivery,
    CheckoutPaymentMethod.sadad,
    CheckoutPaymentMethod.paypal,
    CheckoutPaymentMethod.stripe,
    CheckoutPaymentMethod.plutu,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionHeader(
          data: CheckoutSectionHeaderDto(
            title: LocaleKeys.paymentMethod.tr,
            hasError: data.hasError,
            errorMessage: LocaleKeys.selectPayment.tr,
          ),
        ),
        const SizedBox(height: MarketplaceSpacing.sm),
        for (int i = 0; i < _order.length; i++) ...[
          if (i > 0) const SizedBox(height: MarketplaceSpacing.sm),
          CheckoutPaymentCard(
            method: _order[i],
            isSelected: data.selectedMethod == _order[i],
            onTap: () => data.onSelect(_order[i]),
          ),
        ],
      ],
    );
  }
}
