import 'package:equatable/equatable.dart';

class OrderSummaryEntity extends Equatable {
  const OrderSummaryEntity({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    this.orderNumber,
  });

  final String id;
  final String status;
  final double total;
  final DateTime createdAt;

  /// The customer-facing number (`AMZ-…`). The checkout response is not
  /// documented to carry it, so screens omit the row when it is absent rather
  /// than falling back to the UUID.
  final String? orderNumber;

  @override
  List<Object?> get props => [id, status, total, createdAt, orderNumber];
}
