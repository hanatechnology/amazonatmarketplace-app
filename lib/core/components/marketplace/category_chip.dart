import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import 'app_network_image.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final String imageUrl;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MarketplaceSpacing.categoryChipWidth,
        child: Column(
          children: [
            // Image with selected border
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(MarketplaceRadius.cardImage),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  MarketplaceRadius.cardImage - 2,
                ),
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  width: MarketplaceSpacing.categoryChipWidth,
                  height: MarketplaceSpacing.categoryImageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              label,
              style: MarketplaceTypography.cardSubtitle.copyWith(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
