import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class GetPaymentMethodsUseCase
    extends NoInputUseCase<List<PaymentMethod>, CheckoutRepository> {
  GetPaymentMethodsUseCase(super.repository);

  @override
  Future<AppState<List<PaymentMethod>>> call(_) async {
    final result = await repository.getPaymentMethods();
    return resultToState(result: result);
  }
}
