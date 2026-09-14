import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/marketplace_order_repository.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import '../../../../core/errors/error_messages.dart';

/// Loads one page of the customer's order history.
class GetOrdersUseCase
    extends PaginationUseCase<OrderEntity, MarketplaceOrderRepository> {
  GetOrdersUseCase(super.repository);

  @override
  Future<AppState<PaginatedResult<OrderEntity>>> call(
    PaginationInput input,
  ) async {
    final result = await repository.getOrders(
      page: input.page,
      limit: input.limit,
    );

    return result.fold(
      onSuccess: (page) => AppStateSuccess(
        PaginatedResult<OrderEntity>(
          items: page.items.map((model) => model.toEntity()).toList(),
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          totalItems: page.totalItems,
        ),
      ),
      onFailure: (exception) => AppStateError(exception.localizedMessage),
    );
  }
}
