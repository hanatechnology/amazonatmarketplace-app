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
  });

  final String id;
  final String status;
  final double total;
  final DateTime createdAt;

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) =>
      OrderSummaryModel(
        id: json['id'],
        status: json['status'] as String,
        total: (json['subtotal'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  OrderSummaryEntity toEntity() => OrderSummaryEntity(
        id: id,
        status: status,
        total: total,
        createdAt: createdAt,
      );
}

class PaymentInitiationModel {
  const PaymentInitiationModel({
    required this.checkoutUrl,
    this.successRedirectUrl,
    this.cancelRedirectUrl,
  });

  final String checkoutUrl;
  final String? successRedirectUrl;
  final String? cancelRedirectUrl;

  factory PaymentInitiationModel.fromJson(Map<String, dynamic> json) =>
      PaymentInitiationModel(
        checkoutUrl: json['checkoutUrl'] as String,
        successRedirectUrl: json['successRedirectUrl'] as String?,
        cancelRedirectUrl: json['cancelRedirectUrl'] as String?,
      );

  PaymentInitiationEntity toEntity() => PaymentInitiationEntity(
        checkoutUrl: checkoutUrl,
        successRedirectUrl: successRedirectUrl,
        cancelRedirectUrl: cancelRedirectUrl,
      );
}
