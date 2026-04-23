import 'package:marketplace/domain/entities/marketplace/address_entity.dart';

class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.cityId,
    required this.state,
    required this.country,
    this.postalCode,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String cityId;
  final String state;
  final String country;
  final String? postalCode;
  final bool isDefault;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      label: json['label'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      addressLine1: json['address_line_1'] as String,
      addressLine2: json['address_line_2'] as String?,
      cityId: json['city_id'].toString(),
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postal_code'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'full_name': fullName,
    'phone': phone,
    'address_line_1': addressLine1,
    if (addressLine2 != null) 'address_line_2': addressLine2,
    'city_id': cityId,
    'state': state,
    'country': country,
    if (postalCode != null) 'postal_code': postalCode,
    'is_default': isDefault,
  };

  AddressEntity toEntity() => AddressEntity(
    id: id,
    label: label,
    fullName: fullName,
    phone: phone,
    addressLine1: addressLine1,
    addressLine2: addressLine2,
    cityId: cityId,
    state: state,
    country: country,
    postalCode: postalCode,
    isDefault: isDefault,
  );
}
