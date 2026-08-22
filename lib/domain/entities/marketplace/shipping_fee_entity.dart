import 'package:equatable/equatable.dart';

/// Result of `GET /orders/shipping-fee` — what delivery will cost for one
/// vendor to one address, previewed before the order is placed.
class ShippingFeeEntity extends Equatable {
  const ShippingFeeEntity({
    required this.rate,
    required this.isFreeShipping,
    required this.estimatedDays,
    this.zoneName,
  });

  final double rate;
  final bool isFreeShipping;
  final int estimatedDays;
  final String? zoneName;

  /// What the customer is actually charged. A free-shipping zone still reports
  /// its rate, so the flag decides rather than the number.
  double get chargeable => isFreeShipping ? 0 : rate;

  @override
  List<Object?> get props => [rate, isFreeShipping, estimatedDays, zoneName];
}
