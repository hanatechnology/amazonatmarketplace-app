import 'package:equatable/equatable.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';

class VendorSummary extends Equatable {
  final String id;
  final String name;
  final String logoUrl;

  const VendorSummary({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  @override
  List<Object?> get props => [id, name, logoUrl];
}

class CategorySummary extends Equatable {
  final String id;
  final String name;

  const CategorySummary({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class ProductDetailsEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final double rating;
  final String imageUrl;
  final List<String> imageUrls;
  final VendorSummary vendor;
  final CategorySummary category;
  final bool isActive;
  final String? weight;

  const ProductDetailsEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.rating,
    required this.imageUrl,
    required this.imageUrls,
    required this.vendor,
    required this.category,
    required this.isActive,
    this.weight,
  });

  /// Convert to [ProductEntity] for cart operations.
  ProductEntity toProductEntity() {
    return ProductEntity(
      id: id,
      name: name,
      sellerName: vendor.name,
      sellerId: vendor.id,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      rating: rating,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      description: description,
      categoryId: category.id,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        originalPrice,
        discountPercent,
        rating,
        imageUrl,
        imageUrls,
        vendor,
        category,
        isActive,
        weight,
      ];
}
