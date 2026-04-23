import 'package:equatable/equatable.dart';
import 'order_summary_entity.dart';
import 'payment_initiation_entity.dart';

class CheckoutResultEntity extends Equatable {
  const CheckoutResultEntity({
    required this.order,
    this.paymentInitiation,
  });

  final OrderSummaryEntity order;
  final PaymentInitiationEntity? paymentInitiation;

  @override
  List<Object?> get props => [order, paymentInitiation];
}
