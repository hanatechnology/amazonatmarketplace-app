import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String sellerName;
  final String sellerId;

  /// Seller's logo. Empty when the payload carried none — every surface that
  /// shows it falls back to a storefront glyph rather than a broken image.
  final String sellerLogoUrl;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final double rating;
  final String imageUrl;
  final List<String> imageUrls;
  final String? description;
  final String categoryId;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.sellerName,
    required this.sellerId,
    this.sellerLogoUrl = '',
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.rating,
    required this.imageUrl,
    required this.imageUrls,
    this.description,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        sellerName,
        sellerId,
        sellerLogoUrl,
        price,
        originalPrice,
        discountPercent,
        rating,
        imageUrl,
        imageUrls,
        description,
        categoryId,
      ];
}
