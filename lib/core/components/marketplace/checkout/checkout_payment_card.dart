import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';

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

  IconData get icon => switch (this) {
        PaymentMethod.payOnDelivery => Icons.local_shipping_outlined,
        PaymentMethod.sadad => Icons.account_balance_outlined,
        PaymentMethod.paypal => Icons.payment_outlined,
        PaymentMethod.stripe => Icons.credit_card_outlined,
        PaymentMethod.plutu => Icons.account_balance_wallet_outlined,
        PaymentMethod.edfali => Icons.sms_outlined,
        PaymentMethod.unknown => Icons.payment_outlined,
      };
}

/// Single payment method radio card.
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.md,
          vertical: MarketplaceSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? MarketplaceColors.secondary.withValues(alpha: 0.2)
              : MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          border: Border.all(
            color: isSelected
                ? MarketplaceColors.primary
                : MarketplaceColors.stroke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              size: 32,
              color: isSelected
                  ? MarketplaceColors.primary
                  : MarketplaceColors.textSecondary,
            ),
            const SizedBox(width: MarketplaceSpacing.md),
            Expanded(
              child: Text(
                method.displayName,
                style: MarketplaceTypography.body.copyWith(
                  color: isSelected
                      ? MarketplaceColors.primary
                      : MarketplaceColors.textBody,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? MarketplaceColors.primary
                  : MarketplaceColors.stroke,
            ),
          ],
        ),
      ),
    );
  }
}
