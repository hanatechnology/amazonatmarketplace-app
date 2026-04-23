import 'package:flutter/material.dart';
import 'product_review_dto.dart';

/// Data passed into [ProductReviewsSection].
class ProductReviewsSectionDto {
  const ProductReviewsSectionDto({
    required this.reviews,
    required this.averageRating,
    this.totalReviews = 0,
    this.onSeeAll,
  });

  /// Preview list of reviews shown on the detail page (typically 2).
  final List<ProductReviewDto> reviews;

  /// Average rating on a 0–5 scale — displayed in the summary header.
  final double averageRating;

  /// Total review count shown in the header.
  /// TODO: populate from backend once available.
  final int totalReviews;

  /// Called when the user taps "See All Reviews".
  final VoidCallback? onSeeAll;
}
