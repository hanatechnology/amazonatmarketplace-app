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
    required this.vendorId,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.rating,
    required this.imageUrl,
    required this.imageUrls,
    required this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      vendorNameAr: json['store_name_ar'] as String,
      vendorNameEn: json['store_name_en'] as String,
      vendorId: json['vendor_id'] as String,
      price: (json['base_price'] as String),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      discountPercent: json['discountPercent'] as int?,
      // rating: (json['rating'] as num).toDouble(),
      rating: 2.0,
      imageUrl: json['image_url'] as String,
      imageUrls: List<String>.from(json['images'] as List<dynamic>),
      descriptionAr: json['description_ar'] as String,
      descriptionEn: json['description_en'] as String,
      categoryId: json['category_id'] as String,
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
      price: double.parse(price),
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
