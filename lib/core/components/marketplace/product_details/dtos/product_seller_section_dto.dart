import 'package:flutter/material.dart';

/// Data passed into [ProductSellerSection].
class ProductSellerSectionDto {
  const ProductSellerSectionDto({
    required this.imageUrl,
    required this.name,
    this.location,
    required this.rating,
    required this.isVerified,
    required this.isOpen,
    required this.followerCount,
    required this.onFollow,
    this.onSeeAll,
  });

  final String imageUrl;
  final String name;
  final String? location;

  /// Seller rating on a 0–5 scale.
  final double rating;

  final bool isVerified;
  final bool isOpen;
  final int followerCount;

  /// Called when the user taps the Follow button.
  final VoidCallback onFollow;

  /// Called when the user taps "All Sellers" — navigates to the sellers list.
  final VoidCallback? onSeeAll;
}
