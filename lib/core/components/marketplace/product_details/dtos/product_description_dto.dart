import 'package:flutter/material.dart';

/// Data passed into [ProductDescriptionSection].
class ProductDescriptionDto {
  const ProductDescriptionDto({
    required this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  /// Product description text. Widget renders nothing when null or empty.
  final String? description;

  /// Whether the full text is currently expanded.
  final bool isExpanded;

  /// Called when the user taps "Show more" / "Show less".
  final VoidCallback onToggle;
}
