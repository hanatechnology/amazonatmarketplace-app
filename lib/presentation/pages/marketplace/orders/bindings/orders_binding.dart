import 'package:get/get.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_orders_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_order_details_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetOrdersUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetOrderDetailsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => OrdersController(), fenix: true);
  }
}
