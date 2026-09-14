import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/product_details_entity.dart';

/// `GET /products/{id}` — "Product detail with all relations".
///
/// Parsing is defensive on shape but never on meaning: every field read here is
/// one the endpoint documents. `images` is accepted both as a list of URL
/// strings (the `/products` list shape) and as a list of objects carrying
/// `image_url` / `is_primary` (the `/stores/{id}/products` shape), because the
/// detail payload has been seen in both forms.
class ProductDetailsModel {
  ProductDetailsModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.vendorId,
    required this.vendorNameAr,
    required this.vendorNameEn,
    required this.vendorLogoUrl,
    required this.price,
    required this.imageUrl,
    required this.imageUrls,
    required this.categoryId,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.isActive,
    required this.isFeatured,
    this.featuredSection,
    this.weight,
    this.sku,
    this.createdAt,
    this.stockQuantity = 0,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String vendorId;
  final String vendorNameAr;
  final String vendorNameEn;
  final String vendorLogoUrl;
  final String price;
  final String imageUrl;
  final List<String> imageUrls;
  final String categoryId;
  final String categoryNameAr;
  final String categoryNameEn;
  final bool isActive;
  final bool isFeatured;
  final String? featuredSection;
  final String? weight;
  final String? sku;
  final DateTime? createdAt;

  /// `stock_quantity` — units the customer may order.
  final int stockQuantity;

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    final vendor = _asMap(json['vendor']);
    final category = _asMap(json['category']);
    final images = _imageUrls(json['images']);

    return ProductDetailsModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      vendorId: vendor['id']?.toString() ?? '',
      vendorNameAr: vendor['name_ar'] as String? ?? '',
      vendorNameEn: vendor['name_en'] as String? ?? '',
      vendorLogoUrl: vendor['logo_url'] as String? ?? '',
      price: json['base_price']?.toString() ?? '0',
      imageUrl: json['image_url'] as String? ??
          _primaryImageUrl(json['images']) ??
          (images.isEmpty ? '' : images.first),
      imageUrls: images,
      categoryId: category['id']?.toString() ??
          json['category_id']?.toString() ??
          '',
      categoryNameAr: category['name_ar'] as String? ?? '',
      categoryNameEn: category['name_en'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      featuredSection: json['featured_section'] as String?,
      weight: json['weight']?.toString(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      sku: json['sku'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  ProductDetailsEntity toEntity() {
    final isAr = Get.locale?.languageCode == 'ar';
    return ProductDetailsEntity(
      id: id,
      name: isAr ? nameAr : nameEn,
      description: isAr ? descriptionAr : descriptionEn,
      price: double.tryParse(price) ?? 0,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      vendor: VendorSummary(
        id: vendorId,
        name: isAr ? vendorNameAr : vendorNameEn,
        logoUrl: vendorLogoUrl,
      ),
      category: CategorySummary(
        id: categoryId,
        name: isAr ? categoryNameAr : categoryNameEn,
      ),
      isActive: isActive,
      isFeatured: isFeatured,
      featuredSection: featuredSection,
      weight: weight,
      sku: sku,
      createdAt: createdAt,
      stockQuantity: stockQuantity,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) =>
      value is Map<String, dynamic> ? value : const {};

  /// Accepts `["url", …]` and `[{image_url: "url"}, …]` alike.
  static List<String> _imageUrls(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((image) {
          if (image is String) return image;
          if (image is Map<String, dynamic>) {
            return image['image_url'] as String? ?? '';
          }
          return '';
        })
        .where((url) => url.isNotEmpty)
        .toList();
  }

  /// The image the payload marks `is_primary`, when it uses the object shape.
  static String? _primaryImageUrl(dynamic raw) {
    if (raw is! List) return null;
    for (final image in raw) {
      if (image is Map<String, dynamic> && image['is_primary'] == true) {
        final url = image['image_url'] as String? ?? '';
        if (url.isNotEmpty) return url;
      }
    }
    return null;
  }
}
