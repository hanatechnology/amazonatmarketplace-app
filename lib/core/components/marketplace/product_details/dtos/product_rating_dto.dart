import 'package:flutter/material.dart';

/// Data passed into [ProductRatingRow].
class ProductRatingDto {
  const ProductRatingDto({
    required this.rating,
    this.reviewCount = 0,
    this.onTap,
  });

  /// Average rating on a 0–5 scale.
  final double rating;

  /// Total number of reviews — shown beside the stars.
  /// TODO: populate from backend when reviewCount is added to ProductEntity.
  final int reviewCount;

  /// Optional tap handler — navigates to the full reviews page.
  final VoidCallback? onTap;
}
