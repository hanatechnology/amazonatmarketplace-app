import 'package:marketplace/core/bases/base_list_response.dart';
import 'package:marketplace/core/bases/base_paginated_response.dart';
import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/data/models/marketplace/product_model.dart';
import 'package:marketplace/data/models/marketplace/product_details_model.dart';
import 'package:marketplace/data/models/marketplace/category_model.dart';
import 'package:marketplace/data/models/marketplace/review_model.dart';

class ProductRepository extends BaseRepository<ApiService> {
  ProductRepository(super.service);

  Future<Result<List<ProductModel>>> getProducts({
    int page = 1,
    int limit = 20,
  }) {
    return get(
      '/products',
      (json) => BasePaginatedResponse.fromJson(
          json, (jsonData) => ProductModel.fromJson(jsonData)).data,
      queryParams: {'page': page, 'limit': limit},
    );
  }

  Future<Result<ProductDetailsModel>> getProductById(String id) {
    return get(
      '/products/$id',
      (json) => BaseResponse.fromJson(
          json, (jsonData) => ProductDetailsModel.fromJson(jsonData)).data,
    );
  }

  Future<Result<List<ProductModel>>> searchProducts(String query) {
    return get(
      '/products/search',
      (json) => (json as List<dynamic>)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      queryParams: {'q': query},
    );
  }

  Future<Result<List<CategoryModel>>> getCategories() {
    return get(
      '/categories',
      (json) => BasePaginatedResponse.fromJson(
          json, (jsonData) => CategoryModel.fromJson(jsonData)).data,
    );
  }

  Future<Result<List<ReviewModel>>> getProductReviews(String productId) {
    return get(
      '/products/$productId/reviews',
      (json) => (json as List<dynamic>)
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
