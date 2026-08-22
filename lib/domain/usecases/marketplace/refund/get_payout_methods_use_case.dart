import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/refund_repository.dart';
import 'package:marketplace/domain/entities/marketplace/payout_method_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class GetPayoutMethodsUseCase
    extends NoInputUseCase<List<PayoutMethodEntity>, RefundRepository> {
  GetPayoutMethodsUseCase(super.repository);

  @override
  Future<AppState<List<PayoutMethodEntity>>> call(_) async {
    final result = await repository.getPayoutMethods();
    return resultToStateWithMapping(
      result: result,
      // Sorted by the backend's own ordering so the picker matches the web.
      mapper: (models) {
        final entities =
            models.map((model) => model.toEntity()).toList();
        entities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return entities;
      },
    );
  }
}
