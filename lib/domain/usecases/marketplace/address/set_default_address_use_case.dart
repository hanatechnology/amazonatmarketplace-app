import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/address_repository.dart';
import 'package:marketplace/domain/entities/marketplace/address_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// Promotes one address to default via `PATCH /addresses/{id}`.
///
/// Returns the updated address rather than void: the patch responds with the
/// full record, and the list uses it instead of guessing what changed.
class SetDefaultAddressUseCase
    extends BaseUseCase<String, AddressEntity, AddressRepository> {
  SetDefaultAddressUseCase(super.repository);

  @override
  Future<AppState<AddressEntity>> call(String id) async {
    final result = await repository.setDefaultAddress(id);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
