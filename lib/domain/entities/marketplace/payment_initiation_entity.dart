import 'package:equatable/equatable.dart';

class PaymentInitiationEntity extends Equatable {
  const PaymentInitiationEntity({
    required this.checkoutUrl,
    this.successRedirectUrl,
    this.cancelRedirectUrl,
  });

  final String checkoutUrl;
  final String? successRedirectUrl;
  final String? cancelRedirectUrl;

  @override
  List<Object?> get props => [checkoutUrl, successRedirectUrl, cancelRedirectUrl];
}
