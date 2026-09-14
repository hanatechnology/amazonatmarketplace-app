import 'package:equatable/equatable.dart';

import 'local_cart_item_entity.dart';

/// One store's slice of the cart.
///
/// The cart holds items from any number of stores, but `POST /orders/checkout`
/// takes one vendor per order and the shipping fee is priced per vendor. So the
/// cart groups by store and each group checks out on its own — the same shape
/// the web client uses, where paying for one store leaves the rest in the cart.
class CartVendorGroup extends Equatable {
  const CartVendorGroup({
    required this.vendorId,
    required this.vendorName,
    required this.items,
    this.vendorLogoUrl = '',
  });

  final String vendorId;
  final String vendorName;

  /// Taken from the group's first item — every item in a group is that store's.
  final String vendorLogoUrl;

  final List<LocalCartItemEntity> items;

  /// Distinct products, not total quantity — matches the web's item count.
  int get itemCount => items.length;

  /// Sum of the line totals. Line prices are already the selling price, so this
  /// is what the customer pays for goods, before delivery.
  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.lineTotal);

  /// What the original prices would have cost, minus [subtotal]. Informational
  /// only — never subtract it again, it is already reflected in the line price.
  double get savings => items.fold(0, (sum, item) => sum + item.lineSaving);

  /// Groups a flat cart into per-store groups, preserving the order items were
  /// added in so the list does not reshuffle under the customer.
  static List<CartVendorGroup> from(List<LocalCartItemEntity> items) {
    final order = <String>[];
    final byVendor = <String, List<LocalCartItemEntity>>{};

    for (final item in items) {
      if (!byVendor.containsKey(item.sellerId)) {
        byVendor[item.sellerId] = [];
        order.add(item.sellerId);
      }
      byVendor[item.sellerId]!.add(item);
    }

    return order
        .map((vendorId) => CartVendorGroup(
              vendorId: vendorId,
              vendorName: byVendor[vendorId]!.first.sellerName,
              vendorLogoUrl: byVendor[vendorId]!.first.sellerLogoUrl,
              items: byVendor[vendorId]!,
            ))
        .toList();
  }

  @override
  List<Object?> get props => [vendorId, items];
}
