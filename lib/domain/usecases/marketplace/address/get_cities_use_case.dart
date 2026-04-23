import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/city_entity.dart';
import 'package:marketplace/data/repositories/address_repository.dart';

class GetCitiesUseCase
    extends NoInputUseCase<List<CityEntity>, AddressRepository> {
  GetCitiesUseCase(super.repository);

  @override
  Future<AppState<List<CityEntity>>> call(void input) async {
    final result = await repository.getCities();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}
