import 'package:get/get.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/get_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/add_to_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/remove_from_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/update_local_cart_quantity_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/toggle_local_cart_selection_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/set_local_cart_select_all_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/clear_local_cart_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/checkout_use_case.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/presentation/controllers/marketplace/cart_controller.dart';
import 'package:marketplace/data/services/api_service.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CheckoutRepository(Get.find<ApiService>()), fenix: true);
    // LocalCartRepository is registered permanently in InitialBinding
    Get.lazyPut(() => GetLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => AddToLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => RemoveFromLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => UpdateLocalCartQuantityUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ToggleLocalCartSelectionUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => SetLocalCartSelectAllUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ClearLocalCartUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CheckoutUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CartController(), fenix: true);
  }
}
