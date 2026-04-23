import 'package:flutter/material.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';

/// All supported payment methods.
enum CheckoutPaymentMethod {
  payOnDelivery,
  sadad,
  paypal,
  stripe,
  plutu;

  String get apiValue => switch (this) {
        payOnDelivery => 'PAY_ON_DELIVERY',
        sadad => 'SADAD',
        paypal => 'PAYPAL',
        stripe => 'STRIPE',
        plutu => 'PLUTU',
      };

  String get displayName => switch (this) {
        payOnDelivery => 'Cash on Delivery',
        sadad => 'SADAD',
        paypal => 'PayPal',
        stripe => 'Stripe',
        plutu => 'PLUTU',
      };

  IconData get icon => switch (this) {
        payOnDelivery => Icons.local_shipping_outlined,
        sadad => Icons.account_balance_outlined,
        paypal => Icons.payment_outlined,
        stripe => Icons.credit_card_outlined,
        plutu => Icons.account_balance_wallet_outlined,
      };

  bool get requiresWebView => switch (this) {
        paypal => true,
        stripe => true,
        plutu => true,
        sadad => true,
        _ => false,
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

  final CheckoutPaymentMethod method;
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
