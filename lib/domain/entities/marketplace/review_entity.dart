import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userName;
  final String avatarUrl;
  final double rating;
  final String text;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        avatarUrl,
        rating,
        text,
        createdAt,
      ];
}
