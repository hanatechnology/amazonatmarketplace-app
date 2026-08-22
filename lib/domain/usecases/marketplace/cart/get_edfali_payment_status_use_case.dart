import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/domain/entities/marketplace/edfali_payment_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class GetEdfaliPaymentStatusUseCase extends BaseUseCase<String,
    EdfaliPaymentStatusEntity, CheckoutRepository> {
  GetEdfaliPaymentStatusUseCase(super.repository);

  @override
  Future<AppState<EdfaliPaymentStatusEntity>> call(String orderId) async {
    final result = await repository.getEdfaliPaymentStatus(orderId);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
