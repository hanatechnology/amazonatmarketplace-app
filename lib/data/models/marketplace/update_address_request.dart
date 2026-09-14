import 'package:marketplace/domain/entities/marketplace/address_location.dart';

/// `PATCH /addresses/{id}` body.
///
/// `UpdateAddressDto` requires nothing — it is a partial update — so only the
/// fields actually being changed are sent. That is what makes "set as default"
/// a one-key patch rather than a full round-trip of the address.
class UpdateAddressRequest {
  const UpdateAddressRequest({
    required this.id,
    this.fullName,
    this.phone,
    this.addressLine1,
    this.cityId,
    this.location,
    this.label,
    this.addressLine2,
    this.state,
    this.country,
    this.isDefault,
  });

  /// The documented way to promote an address: there is no
  /// `/addresses/{id}/set-default` endpoint in the spec.
  factory UpdateAddressRequest.setDefault(String id) =>
      UpdateAddressRequest(id: id, isDefault: true);

  final String id;
  final String? fullName;
  final String? phone;
  final String? addressLine1;
  final String? cityId;
  final AddressLocation? location;
  final String? label;
  final String? addressLine2;
  final String? state;
  final String? country;
  final bool? isDefault;

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (addressLine1 != null) 'address_line_1': addressLine1,
        if (cityId != null) 'city_id': cityId,
        if (location != null) 'location': location!.toJson(),
        if (label != null) 'label': label,
        if (addressLine2 != null) 'address_line_2': addressLine2,
        if (state != null) 'state': state,
        if (country != null) 'country': country,
        if (isDefault != null) 'is_default': isDefault,
      };
}
