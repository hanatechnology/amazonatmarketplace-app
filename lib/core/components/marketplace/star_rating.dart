import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_icons.dart';

/// Star rating display widget.
/// Shows filled and outlined stars with optional label.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.maxStars = 5,
    this.showLabel = false,
  });

  final double rating;
  final double size;
  final int maxStars;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        Wrap(
          spacing: -2, // Negative gap between stars
          children: List.generate(
            maxStars,
            (index) {
              final starRating = index + 1;
              final isFilled = rating >= starRating;
              final isHalf = rating > index && rating < starRating;

              return Icon(
                isFilled || isHalf
                    ? MarketplaceIcons.star
                    : MarketplaceIcons.starOutline,
                size: size,
                color: isFilled || isHalf
                    ? MarketplaceColors.primary
                    : MarketplaceColors.textMuted,
              );
            },
          ),
        ),
        // Label
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: MarketplaceTypography.cardRating,
          ),
        ],
      ],
    );
  }
}
