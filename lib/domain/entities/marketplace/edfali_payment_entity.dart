import 'package:equatable/equatable.dart';

/// Gateway-side state of a payment.
enum PaymentStatus {
  initiated,

  /// Edfali: an SMS code was sent — the customer must confirm to complete.
  awaitingConfirmation,

  /// Edfali: a confirmation is in flight.
  confirming,

  /// The gateway gave no usable answer, so the payment may or may not have gone
  /// through. Never show this as failed, and never offer to pay again.
  pendingManualReview,
  captured,
  failed,
  refunded,
  unknown;

  static PaymentStatus fromWire(String? value) => switch (value) {
        'INITIATED' => PaymentStatus.initiated,
        'AWAITING_CONFIRMATION' => PaymentStatus.awaitingConfirmation,
        'CONFIRMING' => PaymentStatus.confirming,
        'PENDING_MANUAL_REVIEW' => PaymentStatus.pendingManualReview,
        'CAPTURED' => PaymentStatus.captured,
        'FAILED' => PaymentStatus.failed,
        'REFUNDED' => PaymentStatus.refunded,
        _ => PaymentStatus.unknown,
      };

  bool get isSettled =>
      this == PaymentStatus.captured || this == PaymentStatus.refunded;
}

/// `GET /orders/{id}/payment/status` — lets the app resume an interrupted
/// Edfali checkout, where the customer still holds a valid SMS code.
class EdfaliPaymentStatusEntity extends Equatable {
  const EdfaliPaymentStatusEntity({
    required this.paymentId,
    required this.orderId,
    required this.status,
    required this.requiresOtp,
    required this.attemptsRemaining,
    this.otpSentTo,
    this.expiresAt,
    this.chargedAmount,
    this.chargedCurrency,
  });

  final String paymentId;
  final String orderId;
  final PaymentStatus status;
  final bool requiresOtp;
  final int attemptsRemaining;
  final String? otpSentTo;
  final DateTime? expiresAt;
  final double? chargedAmount;
  final String? chargedCurrency;

  @override
  List<Object?> get props => [
        paymentId,
        orderId,
        status,
        requiresOtp,
        attemptsRemaining,
        otpSentTo,
        expiresAt,
        chargedAmount,
        chargedCurrency,
      ];
}

/// Business error codes `POST /orders/{id}/payment/confirm` can return with 400.
abstract class EdfaliErrorCodes {
  EdfaliErrorCodes._();

  /// Retryable. Carries `attempts_remaining`.
  static const String otpInvalid = 'edfali_otp_invalid';

  /// Terminal — the payment failed and the order was cancelled.
  static const String attemptsExceeded = 'edfali_otp_attempts_exceeded';
  static const String sessionExpired = 'edfali_session_expired';
  static const String paymentFailed = 'edfali_payment_failed';
}
