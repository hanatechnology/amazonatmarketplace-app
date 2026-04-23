import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_radius.dart';

/// Discount badge widget displaying percentage off.
/// 28×18 with secondary background color.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({
    super.key,
    required this.percentage,
  });

  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: MarketplaceColors.secondary,
        borderRadius: BorderRadius.circular(MarketplaceRadius.discountBadge),
      ),
      child: Center(
        child: Text(
          '$percentage%',
          style: MarketplaceTypography.micro.copyWith(
            fontWeight: FontWeight.w600,
            color: MarketplaceColors.textBody,
          ),
        ),
      ),
    );
  }
}
