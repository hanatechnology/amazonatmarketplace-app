import 'package:marketplace/core/bases/base_paginated_response.dart';
import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/banner_model.dart';
import 'package:marketplace/data/services/api_service.dart';

class BannerRepository extends BaseRepository<ApiService> {
  BannerRepository(super.service);

  /// `GET /banners` — active banners only, already ordered by `sort_order`
  /// on the backend.
  Future<Result<List<BannerModel>>> getBanners({int limit = 10}) {
    return get(
      '/banners',
      (json) => BasePaginatedResponse.fromJson(
        json as Map<String, dynamic>,
        (item) => BannerModel.fromJson(item as Map<String, dynamic>),
      ).data,
      queryParams: {
        'page': 1,
        'limit': limit,
        'sortBy': 'sort_order',
        'sortDirection': 'asc',
      },
    );
  }
}
