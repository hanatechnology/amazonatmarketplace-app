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
    required this.vendorName,
    this.vendorLogoUrl = '',
    required this.subtotal,
    required this.discount,
  });

  final List<CheckoutItemRecord> items;

  /// `POST /orders/checkout` requires every item to belong to one vendor, and
  /// the shipping-fee preview is per vendor, so the id is carried explicitly.
  final String vendorId;

  /// Shown in the checkout header — the customer is paying one store of
  /// possibly several in the cart, and needs to see which.
  final String vendorName;

  /// The store's mark, shown beside its name on the checkout header. Empty
  /// falls back to a storefront glyph.
  final String vendorLogoUrl;

  /// Goods total for this store: the sum of line prices, which are already the
  /// selling prices.
  final double subtotal;

  /// What the original prices would have cost, minus [subtotal] — a "you
  /// saved" figure.
  final double discount;

  /// Goods only; delivery is added once the shipping preview returns.
  ///
  /// [discount] is NOT subtracted here: line prices are already discounted, so
  /// taking it off again under-quoted the customer against what the server
  /// actually charges.
  double get total => subtotal;
}

/// Arguments passed to OrderConfirmedPage via Get.arguments.
class OrderConfirmedArgs {
  const OrderConfirmedArgs({
    this.orderId,
    this.orderNumber,
    required this.total,
    required this.paymentMethod,
  });

  final String? orderId;

  /// Customer-facing number for the receipt block. Null when the checkout
  /// response did not carry one — the row is dropped rather than faked.
  final String? orderNumber;

  final double total;
  final String paymentMethod;
}

/// Arguments passed to OrderCancelledPage via Get.arguments.
///
/// Both values are optional: a payment can fall over before an order number is
/// known, and the screen degrades to copy alone.
class OrderCancelledArgs {
  const OrderCancelledArgs({this.orderNumber, this.total});

  final String? orderNumber;
  final double? total;
}
