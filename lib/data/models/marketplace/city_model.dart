import 'package:marketplace/domain/entities/marketplace/city_entity.dart';

class CityModel {
  const CityModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.isActive,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final bool isActive;

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'].toString(),
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  CityEntity toEntity() => CityEntity(id: id, nameAr: nameAr, nameEn: nameEn);
}
