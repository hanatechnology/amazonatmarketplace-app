import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/address_model.dart';
import 'package:marketplace/data/models/marketplace/city_model.dart';
import 'package:marketplace/data/models/marketplace/create_address_request.dart';
import 'package:marketplace/data/models/marketplace/update_address_request.dart';
import 'package:marketplace/data/services/api_service.dart';

class AddressRepository extends BaseRepository<ApiService> {
  AddressRepository(super.service);

  static const _base = '/addresses';
  static const _citiesBase = '/dropdowns/cities';

  /// GET /client/api/v1/addresses  →  { "data": [...] }
  Future<Result<List<AddressModel>>> getAddresses() => get(
        _base,
        (json) => (json['data'] as List<dynamic>)
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  /// POST /client/api/v1/addresses  →  { "data": { ... } }
  Future<Result<AddressModel>> createAddress(CreateAddressRequest request) =>
      post(
        _base,
        (json) => AddressModel.fromJson(json['data'] as Map<String, dynamic>),
        body: request.toJson(),
      );

  /// PUT /client/api/v1/addresses/{id}  →  { "data": { ... } }
  Future<Result<AddressModel>> updateAddress(UpdateAddressRequest request) =>
      patch(
        '$_base/${request.id}',
        (json) => AddressModel.fromJson(json['data'] as Map<String, dynamic>),
        body: request.toJson(),
      );

  /// DELETE /client/api/v1/addresses/{id}
  Future<Result<void>> deleteAddress(String id) => delete('$_base/$id', (_) {});

  /// PATCH /client/api/v1/addresses/{id}/set-default
  Future<Result<void>> setDefaultAddress(String id) =>
      patch('$_base/$id/set-default', (_) {}, body: {});

  /// GET /client/api/v1/dropdowns/cities  →  { "data": [...] }
  Future<Result<List<CityModel>>> getCities() => get(
        _citiesBase,
        (json) => (json['data'] as List<dynamic>)
            .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
