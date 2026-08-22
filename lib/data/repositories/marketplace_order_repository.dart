import 'package:marketplace/core/bases/base_paginated_response.dart';
import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/data/models/marketplace/order_model.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class MarketplaceOrderRepository extends BaseRepository<ApiService> {
  MarketplaceOrderRepository(super.service);

  /// `GET /orders` — history for the signed-in customer, newest first.
  /// There is no status filter on this endpoint; filtering is client-side.
  Future<Result<PaginatedResult<OrderModel>>> getOrders({
    int page = 1,
    int limit = 10,
  }) {
    return get(
      '/orders',
      (json) {
        final response = BasePaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => OrderModel.fromJson(item as Map<String, dynamic>),
        );
        return PaginatedResult<OrderModel>(
          items: response.data,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalItems: response.total,
        );
      },
      queryParams: {'page': page, 'limit': limit},
    );
  }

  /// `GET /orders/{id}` — adds `payments` and `refunds` to the list payload.
  Future<Result<OrderModel>> getOrderById(String id) {
    return get(
      '/orders/$id',
      (json) => BaseResponse.fromJson(
        json as Map<String, dynamic>,
        (data) => OrderModel.fromJson(data as Map<String, dynamic>),
      ).data,
    );
  }

  /// `PATCH /orders/{id}/cancel`. Only valid while the order is PENDING;
  /// anything else comes back 400.
  Future<Result<OrderModel>> cancelOrder(String id, {String? reason}) {
    return patch(
      '/orders/$id/cancel',
      (json) => BaseResponse.fromJson(
        json as Map<String, dynamic>,
        (data) => OrderModel.fromJson(data as Map<String, dynamic>),
      ).data,
      body: {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }
}
