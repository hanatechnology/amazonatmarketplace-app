import 'package:flutter/material.dart';

/// Data passed into [ProductQuantitySection].
class ProductQuantityDto {
  const ProductQuantityDto({
    required this.value,
    required this.onChanged,
  });

  /// Current quantity value (≥ 1).
  final int value;

  /// Called with the new quantity when the user taps + or −.
  final ValueChanged<int> onChanged;
}
