import 'package:equatable/equatable.dart';

class LocalCartItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String imageUrl;
  final String sellerName;
  final String sellerId;

  /// Seller's logo, carried so the cart and checkout can show the storefront
  /// mark without refetching the vendor.
  final String sellerLogoUrl;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final int quantity;
  final bool isSelected;
  final DateTime addedAt;

  const LocalCartItemEntity({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.sellerName,
    required this.sellerId,
    this.sellerLogoUrl = '',
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.quantity,
    required this.isSelected,
    required this.addedAt,
  });

  /// Price × quantity
  double get lineTotal => price * quantity;

  /// Saving per unit × quantity (0 if no original price set)
  double get lineSaving =>
      originalPrice != null ? (originalPrice! - price) * quantity : 0;

  @override
  List<Object?> get props => [productId, quantity, isSelected];
}
