import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/category_entity.dart';

class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      imageUrl: json['icon_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'icon_url': imageUrl,
    };
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: Get.locale?.languageCode == 'ar' ? nameAr : nameEn,
      imageUrl: imageUrl,
    );
  }
}
