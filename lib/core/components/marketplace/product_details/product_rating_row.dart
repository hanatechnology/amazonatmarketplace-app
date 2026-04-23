import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../star_rating.dart';
import '../../../localization/locale_keys.dart';
import 'dtos/product_rating_dto.dart';

/// Displays the average star rating and a tappable review count link.
///
/// Design fix: removed the `(rating * 20).round()` formula that produced
/// nonsensical review counts. [ProductRatingDto.reviewCount] is now explicit.
class ProductRatingRow extends StatelessWidget {
  const ProductRatingRow({super.key, required this.dto});

  final ProductRatingDto dto;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dto.onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StarRating(
            rating: dto.rating,
            size: 20,
            showLabel: true,
          ),
          const SizedBox(width: MarketplaceSpacing.sm),
          Text(
            dto.reviewCount > 0
                ? '(${dto.reviewCount} ${LocaleKeys.reviews.tr})'
                : '(${LocaleKeys.reviews.tr})',
            style: MarketplaceTypography.descriptionBody.copyWith(
              color: MarketplaceColors.link,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
