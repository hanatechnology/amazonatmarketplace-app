import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';

class NotificationTileShimmer extends StatelessWidget {
  const NotificationTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MarketplaceColors.stroke.withValues(alpha: 0.4),
      highlightColor: MarketplaceColors.stroke.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.md,
          vertical: MarketplaceSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MarketplaceSpacing.sm,
              height: MarketplaceSpacing.sm,
              margin: const EdgeInsetsDirectional.only(
                top: MarketplaceSpacing.xs,
                end: MarketplaceSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: 160, height: 14),
                  const SizedBox(height: MarketplaceSpacing.sm),
                  _bar(width: double.infinity, height: 12),
                  const SizedBox(height: MarketplaceSpacing.xs),
                  _bar(width: 220, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MarketplaceSpacing.xs),
      ),
    );
  }
}
