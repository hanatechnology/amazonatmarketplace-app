import 'package:equatable/equatable.dart';

class OrderSummaryEntity extends Equatable {
  const OrderSummaryEntity({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  final String id;
  final String status;
  final double total;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, status, total, createdAt];
}
