import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/checkout_request.dart';
import 'package:marketplace/data/models/marketplace/checkout_result_model.dart';
import 'package:marketplace/data/models/marketplace/edfali_payment_model.dart';
import 'package:marketplace/data/models/marketplace/shipping_fee_model.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/entities/marketplace/edfali_payment_entity.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';

class CheckoutRepository {
  const CheckoutRepository(this._api);

  final ApiService _api;

  Future<Result<CheckoutResultModel>> checkout(CheckoutRequest request) =>
      _api.post(
        '/orders/checkout',
        (data) => BaseResponse.fromJson(
            data, (jsonData) => CheckoutResultModel.fromJson(jsonData)).data,
        body: request.toJson(),
      );

  /// `GET /orders/payment-methods` — only the methods this deployment can
  /// actually complete. Response is `{ payment_methods: [...] }`.
  ///
  /// Anything the backend sends that this app does not recognise is dropped
  /// rather than shown as an unusable option.
  Future<Result<List<PaymentMethod>>> getPaymentMethods() => _api.get(
        '/orders/payment-methods',
        (data) => BaseResponse.fromJson(
          data as Map<String, dynamic>,
          (json) => ((json as Map<String, dynamic>)['payment_methods']
                      as List<dynamic>? ??
                  const [])
              .map((value) => PaymentMethod.fromWire(value as String?))
              .where((method) => method != PaymentMethod.unknown)
              .toList(),
        ).data,
      );

  /// `GET /orders/shipping-fee` — preview for one vendor to one address.
  Future<Result<ShippingFeeModel>> getShippingFee({
    required String vendorId,
    required String addressId,
  }) =>
      _api.get(
        '/orders/shipping-fee',
        (data) => BaseResponse.fromJson(
          data as Map<String, dynamic>,
          (json) => ShippingFeeModel.fromJson(json as Map<String, dynamic>),
        ).data,
        queryParams: {'vendor_id': vendorId, 'address_id': addressId},
      );

  /// `POST /orders/{id}/payment/confirm` — step two of Edfali. The PIN is four
  /// digits and single-use; a wrong one is retryable until the third attempt,
  /// which fails the payment and cancels the order.
  Future<Result<PaymentStatus>> confirmEdfaliPayment({
    required String orderId,
    required String otp,
  }) =>
      _api.post(
        '/orders/$orderId/payment/confirm',
        (data) => BaseResponse.fromJson(
          data as Map<String, dynamic>,
          (json) => ConfirmEdfaliPaymentModel.fromJson(
            json as Map<String, dynamic>,
          ).toEntity(),
        ).data,
        body: {'otp': otp},
      );

  /// `GET /orders/{id}/payment/status` — used to resume an interrupted Edfali
  /// checkout.
  Future<Result<EdfaliPaymentStatusModel>> getEdfaliPaymentStatus(
    String orderId,
  ) =>
      _api.get(
        '/orders/$orderId/payment/status',
        (data) => BaseResponse.fromJson(
          data as Map<String, dynamic>,
          (json) =>
              EdfaliPaymentStatusModel.fromJson(json as Map<String, dynamic>),
        ).data,
      );
}
