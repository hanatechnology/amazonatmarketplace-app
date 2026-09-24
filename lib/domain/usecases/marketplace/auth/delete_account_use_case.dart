import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/auth_repository.dart';
import 'package:marketplace/domain/entities/marketplace/account_deletion_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// Schedules erasure of the signed-in customer's account.
///
/// One-way: on success the session is already dead server-side, so the caller
/// must tear down the local one rather than re-reading anything.
class DeleteAccountUseCase
    extends BaseUseCase<void, AccountDeletionEntity, AuthRepository> {
  DeleteAccountUseCase(super.repository);

  @override
  Future<AppState<AccountDeletionEntity>> call(void input) async {
    final result = await repository.deleteAccount();
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }

  Future<AppState<AccountDeletionEntity>> execute() => call(null);
}
