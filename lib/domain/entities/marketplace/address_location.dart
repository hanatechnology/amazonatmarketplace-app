import 'package:equatable/equatable.dart';

/// `location` on an address — required by `POST /addresses`.
///
/// All three fields are required by `AddressLocationDto`: the coordinate pair
/// the courier navigates to, and a human-readable string to read off. There is
/// no geocoding endpoint in the contract, so [address] is composed from what
/// the customer typed rather than resolved from the pin.
class AddressLocation extends Equatable {
  const AddressLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  /// Centre of Tripoli — where the picker opens when there is nothing to
  /// restore, matching the web client's default.
  static const AddressLocation tripoli = AddressLocation(
    lat: 32.8872,
    lng: 13.1913,
    address: '',
  );

  final double lat;
  final double lng;
  final String address;

  AddressLocation copyWith({double? lat, double? lng, String? address}) =>
      AddressLocation(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        address: address ?? this.address,
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'address': address,
      };

  static AddressLocation? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return AddressLocation(
      lat: lat,
      lng: lng,
      address: json['address'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [lat, lng, address];
}
