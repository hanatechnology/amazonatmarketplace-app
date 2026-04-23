import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final ProductEntity product;
  final int quantity;
  final bool isSelected;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        product,
        quantity,
        isSelected,
      ];
}
