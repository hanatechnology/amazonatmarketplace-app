import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/refund_repository.dart';
import 'package:marketplace/domain/entities/marketplace/refund_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class RequestRefundInput {
  const RequestRefundInput({required this.orderId, required this.request});

  final String orderId;
  final CreateRefundRequest request;
}

class RequestRefundUseCase
    extends BaseUseCase<RequestRefundInput, RefundEntity, RefundRepository> {
  RequestRefundUseCase(super.repository);

  @override
  Future<AppState<RefundEntity>> call(RequestRefundInput input) async {
    final result =
        await repository.requestRefund(input.orderId, input.request);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
