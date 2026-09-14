import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/banner_entity.dart';

/// Wire model for `GET /banners`.
class BannerModel {
  const BannerModel({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.sortOrder,
    this.titleAr,
    this.titleEn,
    this.linkUrl,
    this.productId,
  });

  final String id;
  final String type;
  final String imageUrl;
  final int sortOrder;
  final String? titleAr;
  final String? titleEn;
  final String? linkUrl;
  final String? productId;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'].toString(),
      type: json['type'] as String? ?? 'IMAGE_LINK',
      // The client endpoint only lists banners that carry mobile artwork, and
      // that artwork is what the hero shows — it is cut for a nearly-square
      // block, where the 3:1 web image would lose most of itself to the crop.
      // The web URL stays the fallback for a banner served by an older build.
      imageUrl: _firstNonEmpty([
        json['mobile_image_url'] as String?,
        json['image_url'] as String?,
      ]),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      titleAr: json['title_ar'] as String?,
      titleEn: json['title_en'] as String?,
      linkUrl: json['link_url'] as String?,
      productId: json['product_id'] as String?,
    );
  }

  static String _firstNonEmpty(List<String?> candidates) {
    for (final value in candidates) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  BannerEntity toEntity() {
    final isArabic = Get.locale?.languageCode == 'ar';
    final ar = titleAr ?? '';
    final en = titleEn ?? '';
    final title =
        isArabic ? (ar.isNotEmpty ? ar : en) : (en.isNotEmpty ? en : ar);

    return BannerEntity(
      id: id,
      type: BannerType.fromWire(type),
      imageUrl: imageUrl,
      sortOrder: sortOrder,
      title: title.isEmpty ? null : title,
      linkUrl: linkUrl,
      productId: productId,
    );
  }
}
