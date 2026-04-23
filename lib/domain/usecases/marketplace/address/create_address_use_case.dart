import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/data/models/marketplace/create_address_request.dart';
import 'package:marketplace/data/repositories/address_repository.dart';

class CreateAddressUseCase
    extends BaseUseCase<CreateAddressRequest, AddressEntity, AddressRepository> {
  CreateAddressUseCase(super.repository);

  @override
  Future<AppState<AddressEntity>> call(CreateAddressRequest input) async {
    final result = await repository.createAddress(input);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
