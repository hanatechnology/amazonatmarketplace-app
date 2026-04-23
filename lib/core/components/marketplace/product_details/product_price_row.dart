import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';
import '../discount_badge.dart';
import '../../../localization/locale_keys.dart';
import 'dtos/product_price_dto.dart';

/// Displays the current price, optional strikethrough original price,
/// optional discount badge, and an in-stock / out-of-stock chip.
///
/// Design fixes applied:
/// - Stock status indicator added (was missing from original screen).
/// - Price + badge share a single [Wrap] so they reflow on small screens.
class ProductPriceRow extends StatelessWidget {
  const ProductPriceRow({super.key, required this.dto});

  final ProductPriceDto dto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Price + discount badge ────────────────────────────
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: MarketplaceSpacing.sm,
          runSpacing: MarketplaceSpacing.xs,
          children: [
            Text(
              '\$${dto.price.toStringAsFixed(2)}',
              style: MarketplaceTypography.priceTitle,
            ),
            if (dto.originalPrice != null)
              Text(
                '\$${dto.originalPrice!.toStringAsFixed(2)}',
                style: MarketplaceTypography.priceStrikethrough,
              ),
            if (dto.discountPercent != null)
              DiscountBadge(percentage: dto.discountPercent!),
          ],
        ),

        const SizedBox(height: MarketplaceSpacing.xs),

        // ── Stock status chip ─────────────────────────────────
        _StockChip(isInStock: dto.isInStock),
      ],
    );
  }
}

// ── Stock chip ────────────────────────────────────────────

class _StockChip extends StatelessWidget {
  const _StockChip({required this.isInStock});

  final bool isInStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.sm,
        vertical: MarketplaceSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isInStock
            ? MarketplaceColors.primary.withOpacity(0.1)
            : const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(MarketplaceRadius.badge),
      ),
      child: Text(
        isInStock
            ? LocaleKeys.inStock.tr
            : LocaleKeys.outOfStock.tr,
        style: MarketplaceTypography.micro.copyWith(
          color: isInStock
              ? MarketplaceColors.primary
              : const Color(0xFFD32F2F),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
