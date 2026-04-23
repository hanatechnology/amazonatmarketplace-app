import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_icons.dart';
import 'app_network_image.dart';
import 'quantity_stepper.dart';
import 'discount_badge.dart';

/// Cart item card widget.
/// Intrinsically sized with image, product info, quantity stepper, and delete button.
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.sellerName,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.quantity,
    required this.isSelected,
    required this.onTap,
    required this.onSelect,
    required this.onDelete,
    required this.onQuantityChange,
  });

  final String imageUrl;
  final String name;
  final String sellerName;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final int quantity;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelect;
  final VoidCallback onDelete;
  final ValueChanged<int> onQuantityChange;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: MarketplaceSpacing.cartItemHeight,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: MarketplaceColors.stroke),
          borderRadius: BorderRadius.circular(MarketplaceRadius.cartItem),
          color: MarketplaceColors.surface,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Checkbox
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(MarketplaceSpacing.sm),
                  child: GestureDetector(
                    onTap: () => onSelect(!isSelected),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? MarketplaceColors.primary
                              : MarketplaceColors.stroke,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected ? MarketplaceColors.primary : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: MarketplaceColors.onPrimary,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              // Image container with badge
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    AppNetworkImage(
                      imageUrl: imageUrl,
                      width: MarketplaceSpacing.cartImageWidth,
                      height: MarketplaceSpacing.cartImageHeight,
                      borderRadius: MarketplaceRadius.cardImage,
                      fit: BoxFit.contain,
                    ),
                    if (discountPercent != null)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: DiscountBadge(percentage: discountPercent!),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: MarketplaceSpacing.md),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: MarketplaceTypography.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sellerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MarketplaceTypography.cardSubtitle,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: MarketplaceTypography.cardPrice,
                        ),
                        if (originalPrice != null)
                          Text(
                            '\$${originalPrice!.toStringAsFixed(2)}',
                            style: MarketplaceTypography.cardPrice.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: MarketplaceColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right Column: quantity stepper & delete
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onDelete,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(
                        top: MarketplaceSpacing.sm,
                        right: MarketplaceSpacing.sm,
                      ),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: MarketplaceColors.deleteBackground,
                      ),
                      child: const Icon(
                        MarketplaceIcons.delete,
                        size: 12,
                        color: MarketplaceColors.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: MarketplaceSpacing.sm,
                      bottom: MarketplaceSpacing.sm,
                    ),
                    child: QuantityStepper(
                      value: quantity,
                      onChanged: onQuantityChange,
                      variant: QuantityStepperVariant.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
