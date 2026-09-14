import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../localization/locale_keys.dart';

/// Shown in CartPage when there are no items in the cart.
class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key, this.onShopNow});

  final VoidCallback? onShopNow;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: MarketplaceColors.secondary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: MarketplaceColors.stroke,
              ),
            ),
            const SizedBox(height: MarketplaceSpacing.lg),
            Text(
              LocaleKeys.emptyCart.tr,
              style: MarketplaceTypography.sectionHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.sm),
            Text(
              LocaleKeys.emptyCartMessage.tr,
              style: MarketplaceTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.lg),
            SizedBox(
              height: MarketplaceSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: onShopNow ?? Get.back,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MarketplaceColors.primary,
                  foregroundColor: MarketplaceColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: MarketplaceRadius.buttonBR,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: MarketplaceSpacing.xl,
                  ),
                ),
                child: Text(
                  LocaleKeys.continueShopping.tr,
                  style: MarketplaceTypography.buttonLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
