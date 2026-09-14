import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../theme/marketplace_icons.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/price_formatter.dart';
import '../app_network_image.dart';

/// Compact product card for the horizontal "New arrivals" rail.
///
/// Deliberately lighter than [ProductCard]: no add-to-cart, no wishlist (the
/// API has no favourites endpoint), no border — the rail is for browsing, and
/// the tap target is the whole card.
class HomeProductRailCard extends StatelessWidget {
  const HomeProductRailCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.sellerName,
    required this.price,
    required this.rating,
    required this.onTap,
    this.width = 148,
  });

  final String imageUrl;
  final String name;
  final String sellerName;
  final double price;
  final double rating;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 116,
                width: double.infinity,
                color: palette.surfaceSunken,
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 116,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: MarketplaceTypography.cardHeading.copyWith(
                color: palette.textPrimary,
              ),
              // One line, ellipsised. The rail is a row of equal cards; a name
              // that wraps makes its own card taller than its neighbours.
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              sellerName,
              style: MarketplaceTypography.rowMeta.copyWith(
                color: palette.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text.rich(
                    // Figures and the currency token read left-to-right in
                    // both locales.
                    textDirection: TextDirection.ltr,
                    TextSpan(
                      text: PriceFormatter.amount(price),
                      style: MarketplaceTypography.priceDisplay.copyWith(
                        color: palette.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: ' ${PriceFormatter.unit()}',
                          style: MarketplaceTypography.priceUnit.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (rating > 0) ...[
                  const SizedBox(width: 6),
                  Icon(MarketplaceIcons.star, size: 13, color: palette.star),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: MarketplaceTypography.rowMeta.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder card shown while the rail loads.
class HomeProductRailCardShimmer extends StatelessWidget {
  const HomeProductRailCardShimmer({super.key, this.width = 148});

  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: palette.shimmerBase,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 116,
              width: double.infinity,
              decoration: BoxDecoration(
                color: palette.shimmerBase,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 10),
            bar(width, 11),
            const SizedBox(height: 6),
            bar(width * 0.6, 9),
            const SizedBox(height: 10),
            bar(width * 0.45, 13),
          ],
        ),
      ),
    );
  }
}
