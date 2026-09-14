import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';

class ProductModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String vendorId;
  final String vendorNameAr;
  final String vendorNameEn;

  /// `store_logo_url`. Empty when the payload omitted it.
  final String vendorLogoUrl;
  final String price;
  final double? originalPrice;
  final int? discountPercent;
  final double rating;
  final String imageUrl;
  final List<String> imageUrls;
  final String categoryId;

  ProductModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.vendorNameAr,
    required this.vendorNameEn,
    this.vendorLogoUrl = '',
    required this.vendorId,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.rating,
    required this.imageUrl,
    required this.imageUrls,
    required this.categoryId,
  });

  /// Every field is read defensively. A vendor can save a product before
  /// uploading a photo, and the list payload then carries `image_url: null`
  /// with `images: []` — a non-null cast there threw and took the whole page
  /// down with it, surfacing as a generic error on a grid of 36 good products.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imageUrls = (json['images'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList();

    return ProductModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      vendorNameAr: json['store_name_ar'] as String? ?? '',
      vendorNameEn: json['store_name_en'] as String? ?? '',
      vendorLogoUrl: json['store_logo_url'] as String? ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      price: json['base_price']?.toString() ?? '0',
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      discountPercent: json['discountPercent'] as int?,
      // The product payload carries no rating — there is no rating field in the
      // spec and no reviews endpoint anywhere in it. Zero means "not rated",
      // which is what every card checks before drawing stars; a hardcoded 2.0
      // put a fake two-star score on every product in the app.
      rating: 0,
      // Falls back to the first gallery image so a product with only `images`
      // populated still draws a thumbnail; empty means the card shows its
      // placeholder.
      imageUrl: json['image_url'] as String? ??
          (imageUrls.isEmpty ? '' : imageUrls.first),
      imageUrls: imageUrls,
      descriptionAr: json['description_ar'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      categoryId: json['category_id']?.toString() ?? '',
    );
  }

  /// `GET /stores/{id}/products` returns a different shape from `/products`:
  /// images are objects rather than URLs, and the vendor block is absent
  /// because the caller already knows which store it asked about.
  factory ProductModel.fromStoreJson(
    Map<String, dynamic> json, {
    required String storeName,
  }) {
    final images = (json['images'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final primary = images.firstWhere(
      (image) => image['is_primary'] == true,
      orElse: () => images.isEmpty ? const {} : images.first,
    );

    return ProductModel(
      id: json['id'].toString(),
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      // The caller already resolved the store's name for the active locale, so
      // both language slots carry the same value.
      vendorNameAr: storeName,
      vendorNameEn: storeName,
      vendorId: json['vendor_id']?.toString() ?? '',
      price: json['base_price']?.toString() ?? '0',
      rating: 0,
      imageUrl: primary['image_url'] as String? ?? '',
      imageUrls: images
          .map((image) => image['image_url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
      descriptionAr: json['description_ar'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      categoryId: json['category_id']?.toString() ?? '',
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: Get.locale?.languageCode == 'ar' ? nameAr : nameEn,
      sellerName:
          Get.locale?.languageCode == 'ar' ? vendorNameAr : vendorNameEn,
      sellerId: vendorId,
      sellerLogoUrl: vendorLogoUrl,
      price: double.tryParse(price) ?? 0,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      rating: rating,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      description:
          Get.locale?.languageCode == 'ar' ? descriptionAr : descriptionEn,
      categoryId: categoryId,
    );
  }
}
