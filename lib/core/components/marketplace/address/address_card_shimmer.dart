import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';

class AddressCardShimmer extends StatelessWidget {
  const AddressCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MarketplaceColors.stroke.withValues(alpha: 0.4),
      highlightColor: MarketplaceColors.stroke.withValues(alpha: 0.15),
      child: Container(
        padding: const EdgeInsets.all(MarketplaceSpacing.md),
        decoration: BoxDecoration(
          color: MarketplaceColors.stroke.withValues(alpha: 0.4),
          borderRadius: MarketplaceRadius.cardBR,
          border: Border.all(color: MarketplaceColors.stroke),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location icon placeholder
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: MarketplaceSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: MarketplaceSpacing.xs),
                  Container(
                    height: 13,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 13,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MarketplaceSpacing.xs),
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.xs),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
