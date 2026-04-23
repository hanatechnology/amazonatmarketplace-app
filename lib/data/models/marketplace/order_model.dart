import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime createdAt;
  final String? trackingInfo;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.trackingInfo,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: OrderStatus.values.firstWhere(
        (status) => status.name == json['status'] as String,
        orElse: () => OrderStatus.active,
      ),
      items: (json['items'] as List<dynamic>)
          .map((item) =>
              CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      trackingInfo: json['trackingInfo'] as String?,
    );
  }



  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      status: _convertOrderStatus(status),
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      createdAt: createdAt,
      trackingInfo: trackingInfo,
    );
  }

  static OrderStatus _convertOrderStatus(OrderStatus modelStatus) {
    switch (modelStatus) {
      case OrderStatus.active:
        return OrderStatus.active;
      case OrderStatus.completed:
        return OrderStatus.completed;
      case OrderStatus.cancelled:
        return OrderStatus.cancelled;
    }
  }
}
