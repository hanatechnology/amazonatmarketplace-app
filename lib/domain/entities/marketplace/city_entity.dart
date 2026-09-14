import 'package:equatable/equatable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class CityEntity extends Equatable {
  const CityEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  /// The name for the active locale, falling back to the other one rather than
  /// rendering an empty row when only one translation is filled in.
  String get name {
    final isArabic = Get.locale?.languageCode == 'ar';
    final preferred = isArabic ? nameAr : nameEn;
    return preferred.isNotEmpty ? preferred : (isArabic ? nameEn : nameAr);
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn];
}
