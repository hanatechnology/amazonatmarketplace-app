import 'package:marketplace/domain/entities/marketplace/marketplace_user_entity.dart';
import 'address_model.dart';

class MarketplaceUserModel {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final List<AddressModel> addresses;

  MarketplaceUserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    required this.addresses,
  });

  factory MarketplaceUserModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((address) =>
                  AddressModel.fromJson(address as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'addresses': addresses.map((address) => address.toJson()).toList(),
    };
  }

  MarketplaceUserEntity toEntity() {
    return MarketplaceUserEntity(
      id: id,
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
      addresses: addresses.map((address) => address.toEntity()).toList(),
    );
  }
}
