import 'package:flutter/material.dart';

/// Data passed into [ProductImageGallery].
/// Carries image URLs and an optional callback for page-change events.
class ProductImageGalleryDto {
  const ProductImageGalleryDto({
    required this.imageUrls,
    this.onPageChanged,
  });

  final List<String> imageUrls;

  /// Called with the new page index whenever the user swipes.
  final ValueChanged<int>? onPageChanged;
}
