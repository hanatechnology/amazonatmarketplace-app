import 'package:equatable/equatable.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';

/// The store block `GET /products/{id}` returns inline. It carries the store's
/// name and logo only — verification, rating, follower counts and open/closed
/// live on `GET /stores/{id}` and must not be drawn from here.
class VendorSummary extends Equatable {
  const VendorSummary({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  final String id;
  final String name;
  final String logoUrl;

  @override
  List<Object?> get props => [id, name, logoUrl];
}

class CategorySummary extends Equatable {
  const CategorySummary({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// One product, as the detail endpoint describes it.
///
/// The field list is deliberately exactly what the API returns. There is no
/// rating, no review count, no original price and no discount anywhere in the
/// client contract, so none of them appear here — a detail screen that shows
/// them is showing invented data.
class ProductDetailsEntity extends Equatable {
  const ProductDetailsEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.imageUrls,
    required this.vendor,
    required this.category,
    required this.isActive,
    required this.isFeatured,
    this.featuredSection,
    this.weight,
    this.sku,
    this.createdAt,
    this.stockQuantity = 0,
  });

  final String id;
  final String name;
  final String description;
  final double price;

  /// Primary image, or the first one if the payload marks none.
  final String imageUrl;
  final List<String> imageUrls;

  final VendorSummary vendor;
  final CategorySummary category;

  /// `is_active: false` means the product cannot be ordered. Note the detail
  /// endpoint 404s on inactive products, so this mostly guards a product that
  /// goes inactive while its detail page is open.
  final bool isActive;

  final bool isFeatured;

  /// `NEW_ARRIVALS` / `BEST_SELLERS` / `ADMIN_PICKS`, or null.
  final String? featuredSection;

  final String? weight;
  final String? sku;
  final DateTime? createdAt;

  /// Units in stock, from `stock_quantity`. Zero means the endpoint did not
  /// report any, which is treated as "no known ceiling" rather than "sold out"
  /// — only [isActive] decides whether a product can be ordered at all.
  final int stockQuantity;

  /// Highest quantity the stepper may reach, or null when stock is unknown.
  int? get maxOrderableQuantity => stockQuantity > 0 ? stockQuantity : null;

  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  /// Convert to [ProductEntity] for cart operations. Rating and discount are
  /// zero/null because the contract carries neither for a product.
  ProductEntity toProductEntity() {
    return ProductEntity(
      id: id,
      name: name,
      sellerName: vendor.name,
      sellerId: vendor.id,
      price: price,
      rating: 0,
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
        imageUrl,
        imageUrls,
        vendor,
        category,
        isActive,
        isFeatured,
        featuredSection,
        weight,
        sku,
        createdAt,
      ];
}
