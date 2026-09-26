import 'package:get/get.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/checkout_use_case.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/data/services/api_service.dart';

/// Checkout plumbing for the cart route.
///
/// The cart itself (LocalCartRepository, the local-cart use cases and
/// [CartController]) is registered permanently in `InitialBinding`: it is app
/// state that outlives any route, and registering it here as well used to hand
/// the cart tab a controller that a later route disposal killed.
class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CheckoutRepository(Get.find<ApiService>()), fenix: true);
    Get.lazyPut(() => CheckoutUseCase(Get.find()), fenix: true);
  }
}
