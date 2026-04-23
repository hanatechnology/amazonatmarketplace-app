import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

enum OrderStatus {
  active,
  completed,
  cancelled,
}

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final List<CartItemEntity> items;
  final double totalAmount;
  final DateTime createdAt;
  final String? trackingInfo;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.trackingInfo,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        status,
        items,
        totalAmount,
        createdAt,
        trackingInfo,
      ];
}
