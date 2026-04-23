import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../review_item.dart';
import '../star_rating.dart';
import '../../../localization/locale_keys.dart';
import 'dtos/product_reviews_section_dto.dart';

/// Reviews section for the product details screen.
///
/// Design improvements over the original:
/// - Added a rating summary row (large score + stars + total reviews count)
///   above the review list — gives users immediate context at a glance.
/// - "See All Reviews" uses [LocaleKeys.seeAllReviews] (was missing).
class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({super.key, required this.dto});

  final ProductReviewsSectionDto dto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.reviewsAndRating.tr,
              style: MarketplaceTypography.sectionHeading,
            ),
            if (dto.onSeeAll != null)
              GestureDetector(
                onTap: dto.onSeeAll,
                child: Text(
                  LocaleKeys.seeAllReviews.tr,
                  style: MarketplaceTypography.seeAll,
                ),
              ),
          ],
        ),
        const SizedBox(height: MarketplaceSpacing.md),

        // ── Rating summary ────────────────────────────────────
        _RatingSummary(dto: dto),
        const SizedBox(height: MarketplaceSpacing.md),

        // ── Review list ───────────────────────────────────────
        ...dto.reviews.map(
          (r) => Padding(
            padding:
                const EdgeInsets.only(bottom: MarketplaceSpacing.md),
            child: ReviewItem(
              avatarUrl: r.avatarUrl,
              name: r.name,
              rating: r.rating,
              text: r.text,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Rating summary row ────────────────────────────────────

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.dto});

  final ProductReviewsSectionDto dto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MarketplaceSpacing.md),
      decoration: BoxDecoration(
        color: MarketplaceColors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Large score number
          Text(
            dto.averageRating.toStringAsFixed(1),
            style: MarketplaceTypography.priceTitle.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: MarketplaceColors.primary,
            ),
          ),
          const SizedBox(width: MarketplaceSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StarRating(
                rating: dto.averageRating,
                size: 20,
                showLabel: false,
              ),
              const SizedBox(height: MarketplaceSpacing.xs),
              Text(
                dto.totalReviews > 0
                    ? '${dto.totalReviews} ${LocaleKeys.reviews.tr}'
                    : LocaleKeys.reviews.tr,
                style: MarketplaceTypography.cardSubtitle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
