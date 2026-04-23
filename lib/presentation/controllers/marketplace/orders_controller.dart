import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_orders_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';

const String kOrders = 'orders';

class OrdersController extends BaseStateController<GetOrdersUseCase> {
  final activeTab = 'active'.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() {
    return handleState(
      kOrders,
      () async => await useCase.call(activeTab.value),
    );
  }

  void changeTab(String status) {
    activeTab.value = status;
    loadOrders();
  }

  Future<void> refreshOrders() {
    return handleState(
      kOrders,
      () async => await useCase.call(activeTab.value),
    );
  }
}
