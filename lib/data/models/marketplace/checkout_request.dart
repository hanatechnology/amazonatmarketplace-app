class CheckoutRequest {
  const CheckoutRequest({
    required this.items,
    required this.addressId,
    required this.paymentMethod,
  });

  final List<CheckoutItemRequest> items;
  final String addressId;
  final String paymentMethod;

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        'address_id': addressId,
        'payment_method': paymentMethod,
      };
}

class CheckoutItemRequest {
  const CheckoutItemRequest({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}
