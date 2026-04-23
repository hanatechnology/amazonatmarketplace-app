import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/checkout_request.dart';
import 'package:marketplace/data/models/marketplace/checkout_result_model.dart';
import 'package:marketplace/data/services/api_service.dart';

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
}
