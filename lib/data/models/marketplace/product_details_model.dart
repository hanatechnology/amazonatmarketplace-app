import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/product_details_entity.dart';

class ProductDetailsModel {
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
  final double? originalPrice;
  final int? discountPercent;
  final double rating;
  final String imageUrl;
  final List<String> imageUrls;
  final String categoryId;
  final String categoryNameAr;
  final String categoryNameEn;
  final bool isActive;
  final String? weight;

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
    this.originalPrice,
    this.discountPercent,
    required this.rating,
    required this.imageUrl,
    required this.imageUrls,
    required this.categoryId,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.isActive,
    this.weight,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>;
    final category = json['category'] as Map<String, dynamic>;

    return ProductDetailsModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      vendorId: vendor['id'] as String,
      vendorNameAr: vendor['name_ar'] as String,
      vendorNameEn: vendor['name_en'] as String,
      vendorLogoUrl: vendor['logo_url'] as String? ?? '',
      price: json['base_price'] as String,
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
      categoryId: category['id'] as String,
      categoryNameAr: category['name_ar'] as String,
      categoryNameEn: category['name_en'] as String,
      isActive: json['is_active'] as bool? ?? true,
      weight: json['weight'] as String?,
    );
  }

  ProductDetailsEntity toEntity() {
    final isAr = Get.locale?.languageCode == 'ar';
    return ProductDetailsEntity(
      id: id,
      name: isAr ? nameAr : nameEn,
      description: isAr ? descriptionAr : descriptionEn,
      price: double.parse(price),
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      rating: rating,
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
      weight: weight,
    );
  }
}
