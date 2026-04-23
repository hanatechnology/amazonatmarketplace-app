import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/data/repositories/address_repository.dart';

class DeleteAddressUseCase
    extends VoidUseCase<String, AddressRepository> {
  DeleteAddressUseCase(super.repository);

  @override
  Future<AppState<void>> call(String id) async {
    final result = await repository.deleteAddress(id);
    return resultToState(result: result);
  }
}
