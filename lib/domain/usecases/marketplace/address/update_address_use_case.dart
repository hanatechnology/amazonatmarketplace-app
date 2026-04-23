import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/data/models/marketplace/update_address_request.dart';
import 'package:marketplace/data/repositories/address_repository.dart';

class UpdateAddressUseCase
    extends BaseUseCase<UpdateAddressRequest, AddressEntity, AddressRepository> {
  UpdateAddressUseCase(super.repository);

  @override
  Future<AppState<AddressEntity>> call(UpdateAddressRequest input) async {
    final result = await repository.updateAddress(input);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
