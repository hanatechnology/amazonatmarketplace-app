import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../localization/locale_keys.dart';
import 'dtos/product_add_to_cart_dto.dart';

/// Sticky bottom bar with the running total and an Add to Cart button.
///
/// Design improvement: original bar showed only the button. Now it also
/// displays the total price (unit × quantity) so users can confirm the
/// amount before tapping — reducing cart abandonment from price surprise.
class ProductAddToCartBar extends StatelessWidget {
  const ProductAddToCartBar({super.key, required this.dto});

  final ProductAddToCartDto dto;

  double get _total => dto.unitPrice * dto.quantity;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH,
          vertical: MarketplaceSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: MarketplaceColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Total price column ────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.totalPrice.tr,
                  style: MarketplaceTypography.cardSubtitle,
                ),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: MarketplaceTypography.priceTitle.copyWith(
                    fontSize: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(width: MarketplaceSpacing.md),

            // ── Add to cart button ────────────────────────────
            Expanded(
              child: ElevatedButton(
                onPressed:
                    dto.isAddingToCart ? null : dto.onAddToCart,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    MarketplaceSpacing.buttonHeight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(MarketplaceRadius.button),
                  ),
                  disabledBackgroundColor:
                      MarketplaceColors.primary.withOpacity(0.6),
                ),
                child: dto.isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MarketplaceColors.onPrimary,
                        ),
                      )
                    : Text(
                        LocaleKeys.addToCart.tr,
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
