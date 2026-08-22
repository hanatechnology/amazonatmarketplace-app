import 'package:marketplace/domain/entities/marketplace/edfali_payment_entity.dart';

/// Wire model for `GET /orders/{id}/payment/status`.
class EdfaliPaymentStatusModel {
  const EdfaliPaymentStatusModel({
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
  final String status;
  final bool requiresOtp;
  final int attemptsRemaining;
  final String? otpSentTo;
  final DateTime? expiresAt;
  final num? chargedAmount;
  final String? chargedCurrency;

  factory EdfaliPaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return EdfaliPaymentStatusModel(
      paymentId: json['payment_id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      requiresOtp: json['requires_otp'] as bool? ?? false,
      attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt() ?? 0,
      otpSentTo: json['otp_sent_to'] as String?,
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
      chargedAmount: json['charged_amount'] as num?,
      chargedCurrency: json['charged_currency'] as String?,
    );
  }

  EdfaliPaymentStatusEntity toEntity() => EdfaliPaymentStatusEntity(
        paymentId: paymentId,
        orderId: orderId,
        status: PaymentStatus.fromWire(status),
        requiresOtp: requiresOtp,
        attemptsRemaining: attemptsRemaining,
        otpSentTo: otpSentTo,
        expiresAt: expiresAt,
        chargedAmount: chargedAmount?.toDouble(),
        chargedCurrency: chargedCurrency,
      );
}

/// Wire model for the `POST /orders/{id}/payment/confirm` response.
class ConfirmEdfaliPaymentModel {
  const ConfirmEdfaliPaymentModel({required this.status});

  final String status;

  factory ConfirmEdfaliPaymentModel.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>?;
    return ConfirmEdfaliPaymentModel(
      // The envelope reports `status` alongside the payment object; fall back
      // to the payment's own status when the top-level field is absent.
      status: json['status'] as String? ??
          payment?['status'] as String? ??
          '',
    );
  }

  PaymentStatus toEntity() => PaymentStatus.fromWire(status);
}
