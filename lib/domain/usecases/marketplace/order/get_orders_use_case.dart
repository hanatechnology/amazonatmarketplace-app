import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/data/repositories/marketplace_order_repository.dart';

class GetOrdersUseCase
    extends BaseUseCase<String, List<OrderEntity>, MarketplaceOrderRepository> {
  GetOrdersUseCase(super.repository);

  @override
  Future<AppState<List<OrderEntity>>> call(String status) async {
    final result = await repository.getOrders(status);
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
