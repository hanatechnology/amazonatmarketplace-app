import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/data/models/marketplace/order_model.dart';

class MarketplaceOrderRepository extends BaseRepository<ApiService> {
  MarketplaceOrderRepository(super.service);

  Future<Result<List<OrderModel>>> getOrders(String status) {
    return get(
      '/orders',
      (json) => (json as List<dynamic>)
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      queryParams: {'status': status},
    );
  }

  Future<Result<OrderModel>> getOrderById(String id) {
    return get(
      '/orders/$id',
      (json) => OrderModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<OrderModel>> createOrder(Map<String, dynamic> data) {
    return post(
      '/orders',
      (json) => OrderModel.fromJson(json as Map<String, dynamic>),
      body: data,
    );
  }
}
