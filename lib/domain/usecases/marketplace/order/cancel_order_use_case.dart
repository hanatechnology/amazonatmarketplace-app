import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/marketplace_order_repository.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// Input for [CancelOrderUseCase]. [reason] is optional and capped at 500
/// characters by the API.
class CancelOrderInput {
  const CancelOrderInput({required this.orderId, this.reason});

  final String orderId;
  final String? reason;
}

class CancelOrderUseCase extends BaseUseCase<CancelOrderInput, OrderEntity,
    MarketplaceOrderRepository> {
  CancelOrderUseCase(super.repository);

  @override
  Future<AppState<OrderEntity>> call(CancelOrderInput input) async {
    final result = await repository.cancelOrder(
      input.orderId,
      reason: input.reason,
    );
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
