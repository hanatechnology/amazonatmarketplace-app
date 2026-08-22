import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';

/// Wire model for `GET /stores` and `GET /stores/{id}`.
class SellerModel {
  final String id;
  final String userId;
  final String storeNameAr;
  final String storeNameEn;
  final String? storeDescriptionAr;
  final String? storeDescriptionEn;
  final String? logoUrl;
  final String? bannerUrl;
  final String whatsappNumber;
  final bool isVerified;
  final String? applicationStatus;
  final DateTime? approvedAt;

  const SellerModel({
    required this.id,
    required this.userId,
    required this.storeNameAr,
    required this.storeNameEn,
    this.storeDescriptionAr,
    this.storeDescriptionEn,
    this.logoUrl,
    this.bannerUrl,
    required this.whatsappNumber,
    required this.isVerified,
    this.applicationStatus,
    this.approvedAt,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      storeNameAr: json['store_name_ar'] as String? ?? '',
      storeNameEn: json['store_name_en'] as String? ?? '',
      storeDescriptionAr: json['store_description_ar'] as String?,
      storeDescriptionEn: json['store_description_en'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      whatsappNumber: json['whatsapp_number'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      applicationStatus: json['application_status'] as String?,
      approvedAt: DateTime.tryParse(json['approved_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_name_ar': storeNameAr,
      'store_name_en': storeNameEn,
      'store_description_ar': storeDescriptionAr,
      'store_description_en': storeDescriptionEn,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'whatsapp_number': whatsappNumber,
      'is_verified': isVerified,
      'application_status': applicationStatus,
      'approved_at': approvedAt?.toIso8601String(),
    };
  }

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  SellerEntity toEntity() {
    // Fall back to the other language when a store filled in only one.
    final name = _isArabic
        ? (storeNameAr.isNotEmpty ? storeNameAr : storeNameEn)
        : (storeNameEn.isNotEmpty ? storeNameEn : storeNameAr);
    final description = _isArabic
        ? (storeDescriptionAr ?? storeDescriptionEn)
        : (storeDescriptionEn ?? storeDescriptionAr);

    return SellerEntity(
      id: id,
      name: name,
      description: description,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      whatsappNumber: whatsappNumber,
      isVerified: isVerified,
    );
  }
}
