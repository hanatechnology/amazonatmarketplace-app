import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'address_model.dart';
import 'refund_model.dart';

/// One line of an order, as returned inside `GET /orders` and `GET /orders/{id}`.
class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.nameSnapshotAr,
    required this.nameSnapshotEn,
    required this.unitPriceSnapshot,
    required this.quantity,
    required this.lineTotal,
    this.variationId,
    this.primaryImageUrl,
  });

  final String id;
  final String orderId;
  final String productId;
  final String nameSnapshotAr;
  final String nameSnapshotEn;
  final String unitPriceSnapshot;
  final int quantity;
  final String lineTotal;
  final String? variationId;
  final String? primaryImageUrl;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'].toString(),
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      nameSnapshotAr: json['product_name_snapshot_ar'] as String? ?? '',
      nameSnapshotEn: json['product_name_snapshot_en'] as String? ?? '',
      unitPriceSnapshot: json['unit_price_snapshot']?.toString() ?? '0',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      lineTotal: json['line_total']?.toString() ?? '0',
      variationId: json['variation_id'] as String?,
      primaryImageUrl: json['primary_image_url'] as String?,
    );
  }

  OrderItemEntity toEntity() {
    final isArabic = Get.locale?.languageCode == 'ar';
    final name = isArabic
        ? (nameSnapshotAr.isNotEmpty ? nameSnapshotAr : nameSnapshotEn)
        : (nameSnapshotEn.isNotEmpty ? nameSnapshotEn : nameSnapshotAr);

    return OrderItemEntity(
      id: id,
      productId: productId,
      name: name,
      unitPrice: double.tryParse(unitPriceSnapshot) ?? 0,
      quantity: quantity,
      lineTotal: double.tryParse(lineTotal) ?? 0,
      imageUrl: primaryImageUrl,
    );
  }
}

/// Wire model for `GET /orders`, `GET /orders/{id}`, and the cancel response.
///
/// Money fields arrive as decimal strings and are kept that way until
/// [toEntity] parses them, so no precision is lost in transit.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.vendorId,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.vendorNameAr,
    this.vendorNameEn,
    this.cancellationReason,
    this.refundedAt,
    this.shippingAddress,
    this.refunds = const [],
  });

  final String id;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final String vendorId;
  final String subtotal;
  final String shippingFee;
  final String totalAmount;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final String? vendorNameAr;
  final String? vendorNameEn;
  final String? cancellationReason;
  final DateTime? refundedAt;
  final AddressModel? shippingAddress;

  /// Only `GET /orders/{id}` returns this; the list payload leaves it empty.
  final List<RefundModel> refunds;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>?;
    final address = json['shippingAddress'] as Map<String, dynamic>?;

    return OrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      subtotal: json['subtotal']?.toString() ?? '0',
      shippingFee: json['shipping_fee']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      vendorNameAr: vendor?['store_name_ar'] as String?,
      vendorNameEn: vendor?['store_name_en'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      refundedAt: DateTime.tryParse(json['refunded_at'] as String? ?? ''),
      shippingAddress: address == null ? null : AddressModel.fromJson(address),
      refunds: (json['refunds'] as List<dynamic>? ?? const [])
          .map((item) => RefundModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  OrderEntity toEntity() {
    final isArabic = Get.locale?.languageCode == 'ar';
    final ar = vendorNameAr ?? '';
    final en = vendorNameEn ?? '';
    final vendorName =
        isArabic ? (ar.isNotEmpty ? ar : en) : (en.isNotEmpty ? en : ar);

    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      status: OrderStatus.fromWire(status),
      paymentMethod: PaymentMethod.fromWire(paymentMethod),
      vendorId: vendorId,
      vendorName: vendorName,
      subtotal: double.tryParse(subtotal) ?? 0,
      shippingFee: double.tryParse(shippingFee) ?? 0,
      totalAmount: double.tryParse(totalAmount) ?? 0,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      cancellationReason: cancellationReason,
      refundedAt: refundedAt,
      shippingAddress: shippingAddress?.toEntity(),
      refunds: refunds.map((refund) => refund.toEntity()).toList(),
    );
  }
}
