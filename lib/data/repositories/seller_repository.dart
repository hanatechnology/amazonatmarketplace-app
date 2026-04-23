import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/data/models/marketplace/seller_model.dart';

class SellerRepository extends BaseRepository<ApiService> {
  SellerRepository(super.service);

  Future<Result<List<SellerModel>>> getSellers({int page = 1}) {
    return get(
      '/sellers',
      (json) => (json as List<dynamic>)
          .map((item) => SellerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      queryParams: {'page': page},
    );
  }

  Future<Result<SellerModel>> getSellerById(String id) {
    return get(
      '/sellers/$id',
      (json) => SellerModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
