import 'package:equatable/equatable.dart';
import 'address_entity.dart';
import 'refund_entity.dart';

/// Lifecycle states the API reports on an order.
///
/// `unknown` is a forward-compatibility landing pad: a status added on the
/// backend must not crash the list.
enum OrderStatus {
  pending,
  paid,
  cod,
  processing,
  shipped,
  readyForPickup,
  delivered,
  cancelled,
  refunded,
  unknown;

  static OrderStatus fromWire(String? value) => switch (value) {
        'PENDING' => OrderStatus.pending,
        'PAID' => OrderStatus.paid,
        'COD' => OrderStatus.cod,
        'PROCESSING' => OrderStatus.processing,
        'SHIPPED' => OrderStatus.shipped,
        'READY_FOR_PICKUP' => OrderStatus.readyForPickup,
        'DELIVERED' => OrderStatus.delivered,
        'CANCELLED' => OrderStatus.cancelled,
        'REFUNDED' => OrderStatus.refunded,
        _ => OrderStatus.unknown,
      };

  /// Only a pending order can be cancelled — matches the web client and the
  /// 400 the API returns for any other status.
  bool get isCancellable => this == OrderStatus.pending;

  bool get isDelivered => this == OrderStatus.delivered;
}

/// How the order was paid for.
enum PaymentMethod {
  plutu,
  sadad,
  paypal,
  stripe,
  edfali,
  payOnDelivery,
  unknown;

  static PaymentMethod fromWire(String? value) => switch (value) {
        'PLUTU' => PaymentMethod.plutu,
        'SADAD' => PaymentMethod.sadad,
        'PAYPAL' => PaymentMethod.paypal,
        'STRIPE' => PaymentMethod.stripe,
        'EDFALI' => PaymentMethod.edfali,
        'PAY_ON_DELIVERY' => PaymentMethod.payOnDelivery,
        _ => PaymentMethod.unknown,
      };
}

/// One line of an order. Names and prices are snapshots taken at checkout, so
/// they stay correct even after the product is edited or delisted.
class OrderItemEntity extends Equatable {
  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.imageUrl,
  });

  final String id;
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final String? imageUrl;

  @override
  List<Object?> get props =>
      [id, productId, name, unitPrice, quantity, lineTotal, imageUrl];
}

/// An order as it appears in the history list.
class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.vendorId,
    required this.vendorName,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.cancellationReason,
    this.refundedAt,
    this.shippingAddress,
    this.refunds = const [],
  });

  final String id;
  final String orderNumber;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String vendorId;
  final String vendorName;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final List<OrderItemEntity> items;
  final DateTime createdAt;
  final String? cancellationReason;
  final DateTime? refundedAt;
  final AddressEntity? shippingAddress;

  /// Refund requests raised against this order. Only the detail endpoint
  /// returns them, so this is always empty on a list item.
  final List<RefundEntity> refunds;

  int get itemCount => items.length;

  bool get canCancel => status.isCancellable;

  /// True while any refund request on this order is still being handled. A
  /// second request is rejected by the API in that case.
  bool get hasActiveRefund =>
      refunds.any((refund) => refund.status.isActive);

  /// A refund may be requested once the order is delivered, nothing has been
  /// refunded, and no earlier request is still in flight.
  bool get canRequestRefund =>
      status.isDelivered && refundedAt == null && !hasActiveRefund;

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        status,
        paymentMethod,
        vendorId,
        vendorName,
        subtotal,
        shippingFee,
        totalAmount,
        items,
        createdAt,
        cancellationReason,
        refundedAt,
        shippingAddress,
        refunds,
      ];
}
