import 'package:marketplace/domain/entities/marketplace/local_cart_item_entity.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';

class LocalCartItemModel {
  final String productId;
  final String productName;
  final String imageUrl;
  final String sellerName;
  final String sellerId;
  final String sellerLogoUrl;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final int quantity;
  final bool isSelected;
  final DateTime addedAt;

  const LocalCartItemModel({
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

  factory LocalCartItemModel.fromJson(Map<String, dynamic> json) {
    return LocalCartItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      imageUrl: json['imageUrl'] as String,
      sellerName: json['sellerName'] as String,
      sellerLogoUrl: json['sellerLogoUrl'] as String? ?? '',
      sellerId: json['sellerId'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      discountPercent: json['discountPercent'] as int?,
      quantity: json['quantity'] as int,
      isSelected: json['isSelected'] as bool,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'sellerName': sellerName,
      'sellerLogoUrl': sellerLogoUrl,
      'sellerId': sellerId,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'quantity': quantity,
      'isSelected': isSelected,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  LocalCartItemModel copyWith({
    int? quantity,
    bool? isSelected,
  }) {
    return LocalCartItemModel(
      productId: productId,
      productName: productName,
      imageUrl: imageUrl,
      sellerName: sellerName,
      sellerLogoUrl: sellerLogoUrl,
      sellerId: sellerId,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      addedAt: addedAt,
    );
  }

  LocalCartItemEntity toEntity() {
    return LocalCartItemEntity(
      productId: productId,
      productName: productName,
      imageUrl: imageUrl,
      sellerName: sellerName,
      sellerLogoUrl: sellerLogoUrl,
      sellerId: sellerId,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      quantity: quantity,
      isSelected: isSelected,
      addedAt: addedAt,
    );
  }

  /// Build from a [ProductEntity] when adding to cart for the first time.
  factory LocalCartItemModel.fromProduct(ProductEntity product, int quantity) {
    return LocalCartItemModel(
      productId: product.id,
      productName: product.name,
      imageUrl: product.imageUrl,
      sellerName: product.sellerName,
      sellerLogoUrl: product.sellerLogoUrl,
      sellerId: product.sellerId,
      price: product.price,
      originalPrice: product.originalPrice,
      discountPercent: product.discountPercent,
      quantity: quantity,
      isSelected: true,
      addedAt: DateTime.now(),
    );
  }
}
