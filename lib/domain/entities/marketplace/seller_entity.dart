import 'package:equatable/equatable.dart';

/// A vendor store as the customer sees it.
///
/// Mirrors `GET /stores` — the API calls these "stores", the mobile UI calls
/// them "sellers". Only fields the OAS documents are modelled here; rating,
/// follower count, and open/closed status have no endpoint yet.
class SellerEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String whatsappNumber;
  final bool isVerified;

  const SellerEntity({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.whatsappNumber,
    required this.isVerified,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        bannerUrl,
        whatsappNumber,
        isVerified,
      ];
}
