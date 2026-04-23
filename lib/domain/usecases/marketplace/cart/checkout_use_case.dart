import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/models/marketplace/checkout_request.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/domain/entities/marketplace/checkout_result_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class CheckoutUseCase
    extends BaseUseCase<CheckoutRequest, CheckoutResultEntity, CheckoutRepository> {
  CheckoutUseCase(super.repository);

  @override
  Future<AppState<CheckoutResultEntity>> call(CheckoutRequest input) async {
    final result = await repository.checkout(input);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
