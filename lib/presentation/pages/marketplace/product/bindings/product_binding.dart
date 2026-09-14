import 'package:get/get.dart';
import 'package:marketplace/data/repositories/product_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/product/get_product_details_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/product/get_vendor_products_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/product_details_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    // The repository normally arrives with the main navigation shell, but a
    // product can also be opened straight from a deep link, with no shell
    // underneath it.
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut(() => ProductRepository(Get.find<ApiService>()), fenix: true);
    }

    Get.lazyPut(() => GetProductDetailsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetVendorProductsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ProductDetailsController(), fenix: true);
  }
}
