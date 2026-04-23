import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/data/repositories/marketplace_order_repository.dart';

class GetOrderDetailsUseCase
    extends BaseUseCase<String, OrderEntity, MarketplaceOrderRepository> {
  GetOrderDetailsUseCase(super.repository);

  @override
  Future<AppState<OrderEntity>> call(String orderId) async {
    final result = await repository.getOrderById(orderId);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
