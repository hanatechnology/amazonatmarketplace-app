import 'package:equatable/equatable.dart';

/// What the gateway needs next after `POST /orders/checkout`.
///
/// Exactly one route applies per payment method:
/// * hosted checkout (Stripe and friends) → open [checkoutUrl];
/// * Edfali → [requiresOtp] is true, an SMS code went to [otpSentTo], and the
///   customer must confirm it;
/// * cash on delivery → neither, the order is already captured.
class PaymentInitiationEntity extends Equatable {
  const PaymentInitiationEntity({
    this.paymentId,
    this.checkoutUrl,
    this.successRedirectUrl,
    this.cancelRedirectUrl,
    this.requiresOtp = false,
    this.otpSentTo,
    this.expiresInSeconds,
    this.chargedAmount,
    this.chargedCurrency,
  });

  final String? paymentId;
  final String? checkoutUrl;
  final String? successRedirectUrl;
  final String? cancelRedirectUrl;

  /// Edfali: an SMS code was sent; collect it and confirm.
  final bool requiresOtp;

  /// Edfali: masked destination for the "we texted …" copy.
  final String? otpSentTo;

  /// Edfali: seconds before the gateway session is assumed dead.
  final int? expiresInSeconds;

  /// Amount the gateway actually charged. Equals the order total for Edfali and
  /// cash on delivery; Stripe settles in USD, so it can differ.
  final double? chargedAmount;
  final String? chargedCurrency;

  bool get hasHostedCheckout =>
      checkoutUrl != null && checkoutUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        paymentId,
        checkoutUrl,
        successRedirectUrl,
        cancelRedirectUrl,
        requiresOtp,
        otpSentTo,
        expiresInSeconds,
        chargedAmount,
        chargedCurrency,
      ];
}
