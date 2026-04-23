import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  const CityEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  @override
  List<Object?> get props => [id, nameAr, nameEn];
}
