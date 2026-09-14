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

  /// DELETE /client/api/v1/addresses/{id}
  Future<Result<void>> deleteAddress(String id) => delete('$_base/$id', (_) {});

  /// Promotes an address to default.
  ///
  /// There is no `/addresses/{id}/set-default` endpoint in the spec — this used
  /// to call one and would have 404'd. The documented route is a partial update
  /// carrying only `is_default`.
  Future<Result<AddressModel>> setDefaultAddress(String id) => patch(
        '$_base/$id',
        (json) => AddressModel.fromJson(json['data'] as Map<String, dynamic>),
        body: UpdateAddressRequest.setDefault(id).toJson(),
      );

  /// GET /client/api/v1/dropdowns/cities  →  { "data": [...] }
  Future<Result<List<CityModel>>> getCities() => get(
        _citiesBase,
        (json) => (json['data'] as List<dynamic>)
            .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
