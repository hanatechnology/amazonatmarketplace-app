import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/category_entity.dart';

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.imageUrl,
    this.parentId,
    this.children = const [],
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String imageUrl;
  final String? parentId;

  /// `GET /categories/tree` nests children under the same shape; the flat
  /// `GET /categories` omits the key entirely.
  final List<CategoryModel> children;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // The OAS documents no response schema for /categories, so field
    // nullability is not guaranteed by contract. A category with no icon comes
    // back with a null icon_url, which a plain `as String` cast turns into a
    // crash that takes down the whole home screen.
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      imageUrl: json['icon_url']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      children: (json['children'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'icon_url': imageUrl,
      'parent_id': parentId,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  CategoryEntity toEntity() {
    // Fall back to the other locale's name rather than rendering an empty
    // chip when only one translation is filled in.
    final isArabic = Get.locale?.languageCode == 'ar';
    final preferred = isArabic ? nameAr : nameEn;
    final fallback = isArabic ? nameEn : nameAr;

    return CategoryEntity(
      id: id,
      name: preferred.isNotEmpty ? preferred : fallback,
      imageUrl: imageUrl,
      parentId: parentId,
      children: children.map((child) => child.toEntity()).toList(),
    );
  }
}
