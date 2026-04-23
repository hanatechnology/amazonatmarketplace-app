import 'package:equatable/equatable.dart';
import 'address_entity.dart';

class MarketplaceUserEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final List<AddressEntity> addresses;

  const MarketplaceUserEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    required this.addresses,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        avatarUrl,
        addresses,
      ];
}
