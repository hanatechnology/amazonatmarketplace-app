import 'package:get/get.dart';
import 'package:marketplace/data/repositories/address_repository.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/checkout_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressRepository>(
      () => AddressRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<GetAddressesUseCase>(
      () => GetAddressesUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<CheckoutRepository>(
      () => CheckoutRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<CheckoutUseCase>(
      () => CheckoutUseCase(Get.find<CheckoutRepository>()),
    );
    Get.lazyPut<CheckoutController>(
      () => CheckoutController(),
    );
  }
}
