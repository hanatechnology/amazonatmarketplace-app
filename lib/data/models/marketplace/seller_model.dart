import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';

class SellerModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? location;
  final double rating;
  final bool isVerified;
  final bool isOpen;
  final int followerCount;

  SellerModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.location,
    required this.rating,
    required this.isVerified,
    required this.isOpen,
    required this.followerCount,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String?,
      rating: (json['rating'] as num).toDouble(),
      isVerified: json['isVerified'] as bool? ?? false,
      isOpen: json['isOpen'] as bool? ?? true,
      followerCount: json['followerCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'location': location,
      'rating': rating,
      'isVerified': isVerified,
      'isOpen': isOpen,
      'followerCount': followerCount,
    };
  }

  SellerEntity toEntity() {
    return SellerEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      location: location,
      rating: rating,
      isVerified: isVerified,
      isOpen: isOpen,
      followerCount: followerCount,
    );
  }
}
