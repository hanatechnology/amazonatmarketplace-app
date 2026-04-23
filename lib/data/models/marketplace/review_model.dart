import 'package:marketplace/domain/entities/marketplace/review_entity.dart';

class ReviewModel {
  final String id;
  final String userName;
  final String avatarUrl;
  final double rating;
  final String text;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      userName: userName,
      avatarUrl: avatarUrl,
      rating: rating,
      text: text,
      createdAt: createdAt,
    );
  }
}
