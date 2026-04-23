import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';

/// Base shimmer box — use instead of hardcoded grey containers
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({this.width, this.height, this.borderRadius});
  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MarketplaceColors.stroke.withOpacity(0.4),
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
    );
  }
}

/// Wraps children in a shimmer animation
class _ShimmerWrapper extends StatelessWidget {
  const _ShimmerWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MarketplaceColors.stroke.withOpacity(0.4),
      highlightColor: MarketplaceColors.stroke.withOpacity(0.15),
      child: child,
    );
  }
}

/// Matches ProductCard: 164×231
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: Container(
        width: MarketplaceSpacing.productCardWidth,
        height: MarketplaceSpacing.productCardHeight,
        decoration: BoxDecoration(
          color: MarketplaceColors.stroke.withOpacity(0.4),
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
        ),
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            _ShimmerBox(
              width: double.infinity,
              height: MarketplaceSpacing.productImageHeight,
              borderRadius: MarketplaceRadius.cardImage,
            ),
            const SizedBox(height: 8),
            // Name
            _ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
            const SizedBox(height: 4),
            // Seller
            _ShimmerBox(width: 80, height: 10, borderRadius: 4),
            const SizedBox(height: 8),
            // Price + button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ShimmerBox(width: 60, height: 12, borderRadius: 4),
                _ShimmerBox(width: 24, height: 12, borderRadius: 4),
              ],
            ),
            const Spacer(),
            // Button
            _ShimmerBox(
              width: double.infinity,
              height: 36,
              borderRadius: MarketplaceRadius.smallButton,
            ),
          ],
        ),
      ),
    );
  }
}

/// Matches CartItemCard: full-width × 110
class CartItemShimmer extends StatelessWidget {
  const CartItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: Container(
        height: MarketplaceSpacing.cartItemHeight,
        decoration: BoxDecoration(
          color: MarketplaceColors.stroke.withOpacity(0.4),
          borderRadius: BorderRadius.circular(MarketplaceRadius.cartItem),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Image
            _ShimmerBox(
              width: MarketplaceSpacing.cartImageWidth,
              height: MarketplaceSpacing.cartImageHeight,
              borderRadius: MarketplaceRadius.cardImage,
            ),
            const SizedBox(width: 12),
            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 100, height: 10, borderRadius: 4),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 60, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Matches PromoBanner: full-width × 146
class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: _ShimmerBox(
        width: double.infinity,
        height: MarketplaceSpacing.bannerHeight,
        borderRadius: MarketplaceRadius.card,
      ),
    );
  }
}

/// Matches CategoryChip: 74 × (image + label)
class CategoryChipShimmer extends StatelessWidget {
  const CategoryChipShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: SizedBox(
        width: MarketplaceSpacing.categoryChipWidth,
        child: Column(
          children: [
            _ShimmerBox(
              width: MarketplaceSpacing.categoryChipWidth,
              height: MarketplaceSpacing.categoryImageHeight,
              borderRadius: MarketplaceRadius.cardImage,
            ),
            const SizedBox(height: 4),
            _ShimmerBox(width: 50, height: 10, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
