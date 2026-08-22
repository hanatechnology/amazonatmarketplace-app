import 'package:get/get.dart';
import 'package:marketplace/data/repositories/seller_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/seller/get_seller_details_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/seller/get_seller_products_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/seller_profile_controller.dart';

class SellerBinding extends Bindings {
  @override
  void dependencies() {
    // Normally already registered by MainNavigationBinding; repeated here so a
    // deep link straight to a store still resolves.
    if (!Get.isRegistered<SellerRepository>()) {
      Get.lazyPut(() => SellerRepository(Get.find<ApiService>()), fenix: true);
    }
    Get.lazyPut(() => GetSellerDetailsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetSellerProductsUseCase(Get.find()), fenix: true);

    // Deliberately not fenix: the controller reads its store id from
    // Get.arguments in onInit, so each visit must build a fresh one.
    Get.lazyPut(() => SellerProfileController());
  }
}
