/// Data passed into [ProductPriceRow].
/// Carries price, optional original price, optional discount, and stock status.
class ProductPriceDto {
  const ProductPriceDto({
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.isInStock = true,
  });

  /// Current selling price.
  final double price;

  /// Original / pre-discount price — shown with strikethrough when set.
  final double? originalPrice;

  /// Discount percentage shown in the badge (e.g. 20 for "20%").
  final int? discountPercent;

  /// Whether the product is available to purchase.
  final bool isInStock;
}
