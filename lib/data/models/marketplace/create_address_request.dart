import 'package:marketplace/domain/entities/marketplace/address_location.dart';

/// `POST /addresses` body.
///
/// `CreateAddressDto` requires exactly five fields: `full_name`, `phone`,
/// `address_line_1`, `city_id` and `location`. Everything else is optional and
/// is omitted when empty rather than sent blank.
///
/// `country` is not asked for — the web hardcodes "Libya" and there is no
/// country picker anywhere in the product — and `postal_code` is dropped
/// outright, because Libya does not use postal codes.
class CreateAddressRequest {
  const CreateAddressRequest({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.cityId,
    required this.location,
    this.label,
    this.addressLine2,
    this.state,
    this.country = 'Libya',
    this.isDefault = false,
  });

  final String fullName;
  final String phone;
  final String addressLine1;
  final String cityId;
  final AddressLocation location;

  final String? label;
  final String? addressLine2;
  final String? state;
  final String country;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone': phone,
        'address_line_1': addressLine1,
        'city_id': cityId,
        'location': location.toJson(),
        if (label != null && label!.isNotEmpty) 'label': label,
        if (addressLine2 != null && addressLine2!.isNotEmpty)
          'address_line_2': addressLine2,
        if (state != null && state!.isNotEmpty) 'state': state,
        'country': country,
        'is_default': isDefault,
      };
}
