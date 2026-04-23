import 'package:flutter/material.dart';

/// Data passed into [ProductAddToCartBar].
class ProductAddToCartDto {
  const ProductAddToCartDto({
    required this.isAddingToCart,
    required this.unitPrice,
    required this.quantity,
    this.onAddToCart,
  });

  /// True while the add-to-cart network call is in-flight — shows a spinner.
  final bool isAddingToCart;

  /// Unit price used to compute the displayed total (unitPrice × quantity).
  final double unitPrice;

  /// Current quantity selected by the user.
  final int quantity;

  /// Called when the user taps the Add to Cart button.
  final VoidCallback? onAddToCart;
}
