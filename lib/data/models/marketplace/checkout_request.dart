class CheckoutRequest {
  const CheckoutRequest({
    required this.items,
    required this.addressId,
    required this.paymentMethod,
    this.edfaliMobile,
  });

  final List<CheckoutItemRequest> items;
  final String addressId;
  final String paymentMethod;

  /// Wallet to debit. Required by the API when [paymentMethod] is `EDFALI`;
  /// the server never falls back to the account phone number.
  final String? edfaliMobile;

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        'address_id': addressId,
        'payment_method': paymentMethod,
        if (edfaliMobile != null && edfaliMobile!.isNotEmpty)
          'edfali_mobile': edfaliMobile,
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
