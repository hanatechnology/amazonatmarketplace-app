/// Record type for one item in the checkout payload.
/// productId is String to match [LocalCartItemEntity.productId].
typedef CheckoutItemRecord = ({
  String productId,
  int quantity,
  String imageUrl,
  String productName,
  double productPrice
});

/// Arguments passed from CartPage to CheckoutPage via Get.arguments.
class CheckoutArgs {
  const CheckoutArgs({
    required this.items,
    required this.vendorId,
    required this.subtotal,
    required this.discount,
  });

  final List<CheckoutItemRecord> items;

  /// `POST /orders/checkout` requires every item to belong to one vendor, and
  /// the shipping-fee preview is per vendor, so the id is carried explicitly.
  final String vendorId;

  /// Pre-calculated subtotal for display.
  final double subtotal;

  /// Pre-calculated discount for display.
  final double discount;

  double get total => subtotal - discount;
}

/// Arguments passed to OrderConfirmedPage via Get.arguments.
class OrderConfirmedArgs {
  const OrderConfirmedArgs({
    this.orderId,
    required this.total,
    required this.paymentMethod,
  });

  final String? orderId;
  final double total;
  final String paymentMethod;
}
