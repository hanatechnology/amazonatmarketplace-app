import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/data/repositories/address_repository.dart';

class GetAddressesUseCase
    extends NoInputUseCase<List<AddressEntity>, AddressRepository> {
  GetAddressesUseCase(super.repository);

  @override
  Future<AppState<List<AddressEntity>>> call(void input) async {
    final result = await repository.getAddresses();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}
