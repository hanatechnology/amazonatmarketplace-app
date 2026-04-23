import 'package:get/get.dart';
import 'package:marketplace/domain/usecases/marketplace/product/get_product_details_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/product_details_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetProductDetailsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ProductDetailsController(), fenix: true);
  }
}
