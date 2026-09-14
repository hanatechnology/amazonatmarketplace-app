import 'package:equatable/equatable.dart';

import 'address_location.dart';

class AddressEntity extends Equatable {
  const AddressEntity({
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
    this.location,
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

  /// Required by the create endpoint; nullable here because an address saved
  /// before this field existed comes back without one.
  final AddressLocation? location;

  AddressEntity copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? cityId,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
    AddressLocation? location,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      cityId: cityId ?? this.cityId,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [
        id, label, fullName, phone, addressLine1, addressLine2,
        cityId, state, country, postalCode, isDefault, location,
      ];
}
