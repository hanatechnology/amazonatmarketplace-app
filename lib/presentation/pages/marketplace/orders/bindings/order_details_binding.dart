import 'package:get/get.dart';
import 'package:marketplace/data/repositories/marketplace_order_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/order/cancel_order_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_order_details_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/order_details_controller.dart';

class OrderDetailsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MarketplaceOrderRepository>()) {
      Get.lazyPut(() => MarketplaceOrderRepository(Get.find<ApiService>()),
          fenix: true);
    }
    Get.lazyPut(() => GetOrderDetailsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CancelOrderUseCase(Get.find()), fenix: true);

    // Deliberately not fenix: the controller reads its order id from
    // Get.arguments in onInit, so each visit must build a fresh one.
    Get.lazyPut(() => OrderDetailsController());
  }
}
