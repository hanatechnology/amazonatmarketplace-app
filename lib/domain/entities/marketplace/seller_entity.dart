import 'package:equatable/equatable.dart';

class SellerEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String? location;
  final double rating;
  final bool isVerified;
  final bool isOpen;
  final int followerCount;

  const SellerEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.location,
    required this.rating,
    required this.isVerified,
    required this.isOpen,
    required this.followerCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        location,
        rating,
        isVerified,
        isOpen,
        followerCount,
      ];
}
