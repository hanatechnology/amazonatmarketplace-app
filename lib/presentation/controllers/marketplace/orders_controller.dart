import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_orders_use_case.dart';

const String kOrders = 'orders';

class OrdersController extends BaseStateController<GetOrdersUseCase> {
  static const int kPageSize = 10;

  final hasMore = false.obs;
  final isLoadingMore = false.obs;

  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    _page = 1;
    await _fetchPage(append: false);
  }

  Future<void> refreshOrders() => loadOrders();

  /// Appends the next page. No-op while a page is in flight or the list is done.
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page += 1;
    await _fetchPage(append: true);
    isLoadingMore.value = false;
  }

  Future<void> _fetchPage({required bool append}) async {
    await handlePaginationState<OrderEntity>(
      kOrders,
      () async {
        final state = await useCase.call(
          PaginationInput(page: _page, limit: kPageSize),
        );
        return state.when(
          onInitial: () => const AppStateInitial<List<OrderEntity>>(),
          onLoading: () => const AppStateLoading<List<OrderEntity>>(),
          onSuccess: (paged, message) {
            hasMore.value = paged.hasMore;
            _page = paged.currentPage;
            return AppStateSuccess(paged.items, message: message);
          },
          onError: (message, code) {
            // Roll the cursor back so a retry re-requests the failed page.
            if (append && _page > 1) _page -= 1;
            return AppStateError<List<OrderEntity>>(message, code: code);
          },
        );
      },
      append: append,
    );
  }

  List<OrderEntity> get orders =>
      getOperationData<List<OrderEntity>>(kOrders) ?? const [];

  /// Replaces one order in place — used after a cancel so the list reflects the
  /// new status without losing scroll position.
  void patchOrder(OrderEntity updated) {
    final list = orders;
    final index = list.indexWhere((order) => order.id == updated.id);
    if (index == -1) return;
    final next = [...list]..[index] = updated;
    stateFor<List<OrderEntity>>(kOrders).value = AppStateSuccess(next);
  }
}
