import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String sellerName;
  final String sellerId;
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
