import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/shipping_fee_entity.dart';

/// Wire model for `GET /orders/shipping-fee`.
class ShippingFeeModel {
  const ShippingFeeModel({
    required this.rate,
    required this.isFreeShipping,
    required this.estimatedDays,
    this.zoneNameAr,
    this.zoneNameEn,
  });

  final double rate;
  final bool isFreeShipping;
  final int estimatedDays;
  final String? zoneNameAr;
  final String? zoneNameEn;

  factory ShippingFeeModel.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'] as Map<String, dynamic>?;
    return ShippingFeeModel(
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      isFreeShipping: json['isFreeShipping'] as bool? ?? false,
      estimatedDays: (json['estimatedDays'] as num?)?.toInt() ?? 0,
      zoneNameAr: zone?['name_ar'] as String?,
      zoneNameEn: zone?['name_en'] as String?,
    );
  }

  ShippingFeeEntity toEntity() {
    final isArabic = Get.locale?.languageCode == 'ar';
    final ar = zoneNameAr ?? '';
    final en = zoneNameEn ?? '';
    final zone =
        isArabic ? (ar.isNotEmpty ? ar : en) : (en.isNotEmpty ? en : ar);

    return ShippingFeeEntity(
      rate: rate,
      isFreeShipping: isFreeShipping,
      estimatedDays: estimatedDays,
      zoneName: zone.isEmpty ? null : zone,
    );
  }
}
