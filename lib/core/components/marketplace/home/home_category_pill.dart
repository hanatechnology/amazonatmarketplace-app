import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

/// Text pill used for the home category row.
///
/// The redesign drops the photo chips: at 60px they showed a thumbnail too
/// small to read and pushed the first products off the fold. A pill row scans
/// faster and leaves the photography to the hero and the cards.
///
/// [isSelected] is off by default. On Home these pills open the category page
/// rather than filtering anything in place, so nothing there is ever "current";
/// the selected styling is kept for rows that really do filter.
class HomeCategoryPill extends StatelessWidget {
  const HomeCategoryPill({
    super.key,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? palette.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          border: Border.all(
            color: isSelected ? palette.brand : palette.hairline,
          ),
        ),
        child: Text(
          label,
          style: MarketplaceTypography.pillLabel.copyWith(
            color: isSelected ? palette.onBrand : palette.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Placeholder pill shown while categories load.
class HomeCategoryPillShimmer extends StatelessWidget {
  const HomeCategoryPillShimmer({super.key, this.width = 78});

  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: Container(
        width: width,
        height: 32,
        decoration: BoxDecoration(
          color: palette.shimmerBase,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        ),
      ),
    );
  }
}
