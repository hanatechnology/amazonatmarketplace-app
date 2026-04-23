import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../localization/locale_keys.dart';

class CheckoutBottomBarDto {
  const CheckoutBottomBarDto({
    required this.total,
    required this.isLoading,
    required this.isEnabled,
    required this.onPlaceOrder,
  });

  final double total;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPlaceOrder;
}

/// Sticky bottom bar with total price and Place Order CTA.
class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({super.key, required this.data});

  final CheckoutBottomBarDto data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          MarketplaceSpacing.screenPaddingH,
          MarketplaceSpacing.sm,
          MarketplaceSpacing.screenPaddingH,
          MarketplaceSpacing.md,
        ),
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: SizedBox(
          height: MarketplaceSpacing.buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: data.isEnabled && !data.isLoading
                ? data.onPlaceOrder
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: MarketplaceColors.primary,
              foregroundColor: MarketplaceColors.onPrimary,
              disabledBackgroundColor:
                  MarketplaceColors.primary.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MarketplaceRadius.button),
              ),
            ),
            child: data.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    '${LocaleKeys.placeOrder.tr} · \$${data.total.toStringAsFixed(2)}',
                    style: MarketplaceTypography.buttonLabel,
                  ),
          ),
        ),
      ),
    );
  }
}
