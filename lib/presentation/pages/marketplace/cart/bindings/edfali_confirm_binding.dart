import 'package:get/get.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/data/repositories/marketplace_order_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/confirm_edfali_payment_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/get_edfali_payment_status_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/order/cancel_order_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/edfali_confirm_controller.dart';

class EdfaliConfirmBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CheckoutRepository>()) {
      Get.lazyPut(() => CheckoutRepository(Get.find<ApiService>()),
          fenix: true);
    }
    Get.lazyPut(() => ConfirmEdfaliPaymentUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetEdfaliPaymentStatusUseCase(Get.find()), fenix: true);

    // "Cancel order" is a real action here: the order sits in PENDING until the
    // PIN lands, which is exactly the state the cancel endpoint accepts.
    if (!Get.isRegistered<MarketplaceOrderRepository>()) {
      Get.lazyPut(() => MarketplaceOrderRepository(Get.find<ApiService>()),
          fenix: true);
    }
    Get.lazyPut(() => CancelOrderUseCase(Get.find()), fenix: true);

    // Deliberately not fenix: the controller takes its order from
    // Get.arguments in onInit, so each visit must build a fresh one.
    Get.lazyPut(() => EdfaliConfirmController());
  }
}
