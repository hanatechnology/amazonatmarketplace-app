import 'package:marketplace/core/bases/base_paginated_response.dart';
import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/data/models/marketplace/product_model.dart';
import 'package:marketplace/data/models/marketplace/product_details_model.dart';
import 'package:marketplace/data/models/marketplace/category_model.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class ProductRepository extends BaseRepository<ApiService> {
  ProductRepository(super.service);

  /// `GET /products` — the one browse endpoint. Search, category, vendor, and
  /// featured-section are all query filters on it; there is no `/products/search`.
  Future<Result<List<ProductModel>>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? vendorId,
    String? featuredSection,
    String? sortBy,
    String? sortDirection,
  }) {
    return get(
      '/products',
      (json) => BasePaginatedResponse.fromJson(
          json, (jsonData) => ProductModel.fromJson(jsonData)).data,
      queryParams: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId,
        if (vendorId != null) 'vendor_id': vendorId,
        if (featuredSection != null) 'featured_section': featuredSection,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortDirection != null) 'sortDirection': sortDirection,
      },
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
    return getProducts(search: query);
  }

  /// Same endpoint as [getProducts], but keeps the pagination envelope so
  /// callers can drive infinite scroll. [getProducts] discards it.
  Future<Result<PaginatedResult<ProductModel>>> getProductsPage({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? vendorId,
    String? featuredSection,
    String? sortBy,
    String? sortDirection,
  }) {
    return get(
      '/products',
      (json) {
        final response = BasePaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => ProductModel.fromJson(item as Map<String, dynamic>),
        );
        return PaginatedResult<ProductModel>(
          items: response.data,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalItems: response.total,
        );
      },
      queryParams: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId,
        if (vendorId != null) 'vendor_id': vendorId,
        if (featuredSection != null) 'featured_section': featuredSection,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortDirection != null) 'sortDirection': sortDirection,
      },
    );
  }

  Future<Result<List<CategoryModel>>> getCategories() {
    return get(
      '/categories',
      (json) => BasePaginatedResponse.fromJson(
          json, (jsonData) => CategoryModel.fromJson(jsonData)).data,
    );
  }
}
