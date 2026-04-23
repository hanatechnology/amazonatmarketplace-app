import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/data/repositories/address_repository.dart';

class SetDefaultAddressUseCase
    extends VoidUseCase<String, AddressRepository> {
  SetDefaultAddressUseCase(super.repository);

  @override
  Future<AppState<void>> call(String id) async {
    final result = await repository.setDefaultAddress(id);
    return resultToState(result: result);
  }
}
