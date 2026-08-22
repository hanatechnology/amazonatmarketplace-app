import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/refund_repository.dart';
import 'package:marketplace/domain/entities/marketplace/refund_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class GetRefundReasonsUseCase
    extends NoInputUseCase<List<RefundReasonEntity>, RefundRepository> {
  GetRefundReasonsUseCase(super.repository);

  @override
  Future<AppState<List<RefundReasonEntity>>> call(_) async {
    final result = await repository.getRefundReasons();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
