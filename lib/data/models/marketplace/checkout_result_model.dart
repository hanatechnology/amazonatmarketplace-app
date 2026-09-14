import 'package:marketplace/domain/entities/marketplace/checkout_result_entity.dart';
import 'package:marketplace/domain/entities/marketplace/order_summary_entity.dart';
import 'package:marketplace/domain/entities/marketplace/payment_initiation_entity.dart';

class CheckoutResultModel {
  const CheckoutResultModel({
    required this.order,
    this.paymentInitiation,
  });

  final OrderSummaryModel order;
  final PaymentInitiationModel? paymentInitiation;

  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResultModel(
      order: OrderSummaryModel.fromJson(json['order'] as Map<String, dynamic>),
      paymentInitiation: json['paymentInitiation'] != null
          ? PaymentInitiationModel.fromJson(
              json['paymentInitiation'] as Map<String, dynamic>)
          : null,
    );
  }

  CheckoutResultEntity toEntity() => CheckoutResultEntity(
        order: order.toEntity(),
        paymentInitiation: paymentInitiation?.toEntity(),
      );
}

class OrderSummaryModel {
  const OrderSummaryModel({
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
  final String? orderNumber;

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) =>
      OrderSummaryModel(
        id: json['id'].toString(),
        status: json['status'] as String? ?? '',
        // `total_amount` is what the customer owes; `subtotal` excludes shipping.
        total: (json['total_amount'] as num?)?.toDouble() ??
            (json['subtotal'] as num?)?.toDouble() ??
            0,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
        orderNumber: json['order_number'] as String?,
      );

  OrderSummaryEntity toEntity() => OrderSummaryEntity(
        id: id,
        status: status,
        total: total,
        createdAt: createdAt,
        orderNumber: orderNumber,
      );
}

class PaymentInitiationModel {
  const PaymentInitiationModel({
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

  /// Absent for Edfali and cash on delivery, so it is read as nullable — a hard
  /// cast here used to throw on any non-hosted-checkout order.
  final String? checkoutUrl;

  /// Not documented in the OAS and unused by the web client; read defensively
  /// so the webview can still detect its own success/cancel redirects.
  final String? successRedirectUrl;
  final String? cancelRedirectUrl;

  final bool requiresOtp;
  final String? otpSentTo;
  final int? expiresInSeconds;
  final num? chargedAmount;
  final String? chargedCurrency;

  factory PaymentInitiationModel.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>?;
    return PaymentInitiationModel(
      paymentId: payment?['id']?.toString(),
      checkoutUrl: json['checkoutUrl'] as String?,
      successRedirectUrl: json['successRedirectUrl'] as String?,
      cancelRedirectUrl: json['cancelRedirectUrl'] as String?,
      requiresOtp: json['requiresOtp'] as bool? ?? false,
      otpSentTo: json['otpSentTo'] as String?,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
      chargedAmount: json['chargedAmount'] as num?,
      chargedCurrency: json['chargedCurrency'] as String?,
    );
  }

  PaymentInitiationEntity toEntity() => PaymentInitiationEntity(
        paymentId: paymentId,
        checkoutUrl: checkoutUrl,
        successRedirectUrl: successRedirectUrl,
        cancelRedirectUrl: cancelRedirectUrl,
        requiresOtp: requiresOtp,
        otpSentTo: otpSentTo,
        expiresInSeconds: expiresInSeconds,
        chargedAmount: chargedAmount?.toDouble(),
        chargedCurrency: chargedCurrency,
      );
}
