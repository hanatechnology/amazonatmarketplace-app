import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';

/// Presentation helpers for the API's payment methods.
///
/// The list of usable methods comes from `GET /orders/payment-methods`; this
/// only decides how each one looks.
extension PaymentMethodDisplay on PaymentMethod {
  /// Brand names are shown as-is; only the delivery option reads as a phrase
  /// and gets a localized label.
  String get displayName => switch (this) {
        PaymentMethod.payOnDelivery => LocaleKeys.statusCod.tr,
        PaymentMethod.sadad => 'Sadad',
        PaymentMethod.paypal => 'PayPal',
        PaymentMethod.stripe => 'Stripe',
        PaymentMethod.plutu => 'Plutu',
        PaymentMethod.edfali => 'Edfali',
        PaymentMethod.unknown => LocaleKeys.statusUnknown.tr,
      };

  /// What happens after "Place order" — the one thing a customer cannot guess
  /// from a brand name.
  String? get hint => switch (this) {
        PaymentMethod.payOnDelivery => LocaleKeys.payCodHint.tr,
        PaymentMethod.edfali => LocaleKeys.payEdfaliHint.tr,
        PaymentMethod.sadad ||
        PaymentMethod.paypal ||
        PaymentMethod.stripe ||
        PaymentMethod.plutu =>
          LocaleKeys.payGatewayHint.tr,
        PaymentMethod.unknown => null,
      };

  IconData get icon => switch (this) {
        PaymentMethod.payOnDelivery => Icons.payments_outlined,
        PaymentMethod.sadad => Icons.account_balance_outlined,
        PaymentMethod.paypal => Icons.payment_outlined,
        PaymentMethod.stripe => Icons.credit_card_outlined,
        PaymentMethod.plutu => Icons.account_balance_wallet_outlined,
        PaymentMethod.edfali => Icons.smartphone_outlined,
        PaymentMethod.unknown => Icons.payment_outlined,
      };
}

/// One payment option. Selected takes a brand hairline and the sunken wash;
/// the icon tile inverts so it stays legible against it.
class CheckoutPaymentCard extends StatelessWidget {
  const CheckoutPaymentCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hint = method.hint;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? palette.surfaceSunken : palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? palette.brand : palette.hairline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isSelected ? palette.surface : palette.surfaceSunken,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                method.icon,
                size: 16,
                color: isSelected ? palette.brand : palette.textSecondary,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    method.displayName,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: MarketplaceTypography.rowMeta.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _Radio(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 19,
      height: 19,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? palette.brand : palette.hairline,
          width: 1.6,
        ),
      ),
      child: isSelected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: palette.brand,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
