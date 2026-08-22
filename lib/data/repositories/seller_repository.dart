import 'package:marketplace/core/bases/base_paginated_response.dart';
import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/data/models/marketplace/product_model.dart';
import 'package:marketplace/data/models/marketplace/seller_model.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// The API names these "stores"; the mobile UI calls them "sellers".
class SellerRepository extends BaseRepository<ApiService> {
  SellerRepository(super.service);

  /// `GET /stores` — approved, verified vendor stores.
  ///
  /// [search] maps to the spec's dynamic `filters` param as `contain_name`,
  /// which is how the web client searches this endpoint.
  Future<Result<PaginatedResult<SellerModel>>> getSellers({
    int page = 1,
    int limit = 20,
    String? search,
  }) {
    return get(
      '/stores',
      (json) {
        final response = BasePaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => SellerModel.fromJson(item as Map<String, dynamic>),
        );
        return PaginatedResult<SellerModel>(
          items: response.data,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalItems: response.total,
        );
      },
      queryParams: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'contain_name': search,
      },
    );
  }

  /// `GET /stores/{id}/products`.
  ///
  /// The payload omits the vendor block, so the store's name is passed in and
  /// stamped onto each product — otherwise every card would render a blank
  /// seller line.
  Future<Result<PaginatedResult<ProductModel>>> getSellerProducts(
    String id, {
    int page = 1,
    int limit = 20,
    required String storeName,
  }) {
    return get(
      '/stores/$id/products',
      (json) {
        final response = BasePaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => ProductModel.fromStoreJson(
            item as Map<String, dynamic>,
            storeName: storeName,
          ),
        );
        return PaginatedResult<ProductModel>(
          items: response.data,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalItems: response.total,
        );
      },
      queryParams: {'page': page, 'limit': limit},
    );
  }

  Future<Result<SellerModel>> getSellerById(String id) {
    return get(
      '/stores/$id',
      (json) => BaseResponse.fromJson(
          json, (jsonData) => SellerModel.fromJson(jsonData)).data,
    );
  }
}
