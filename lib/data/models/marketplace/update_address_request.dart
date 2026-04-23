class UpdateAddressRequest {
  const UpdateAddressRequest({
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

  Map<String, dynamic> toJson() => {
    'label': label,
    'full_name': fullName,
    'phone': phone,
    'address_line_1': addressLine1,
    if (addressLine2 != null && addressLine2!.isNotEmpty)
      'address_line_2': addressLine2,
    'city_id': cityId,
    'state': state,
    'country': country,
    if (postalCode != null && postalCode!.isNotEmpty)
      'postal_code': postalCode,
    'is_default': isDefault,
  };
}
