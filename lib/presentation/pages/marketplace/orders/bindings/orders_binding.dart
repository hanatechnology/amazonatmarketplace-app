import 'package:get/get.dart';
import 'package:marketplace/data/repositories/marketplace_order_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_orders_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    // Normally already registered by MainNavigationBinding; repeated here so a
    // deep link straight to the order list still resolves.
    if (!Get.isRegistered<MarketplaceOrderRepository>()) {
      Get.lazyPut(() => MarketplaceOrderRepository(Get.find<ApiService>()),
          fenix: true);
    }
    Get.lazyPut(() => GetOrdersUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => OrdersController(), fenix: true);
  }
}
