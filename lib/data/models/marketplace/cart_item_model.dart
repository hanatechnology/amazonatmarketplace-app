import 'package:marketplace/domain/entities/marketplace/cart_item_entity.dart';
import 'product_model.dart';

class CartItemModel {
  final String id;
  final String productId;
  final ProductModel product;
  final int quantity;
  final bool isSelected;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.isSelected,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }


  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      productId: productId,
      product: product.toEntity(),
      quantity: quantity,
      isSelected: isSelected,
    );
  }
}
