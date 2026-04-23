import 'package:get/get.dart';
import '../../../../controllers/marketplace/products_list_controller.dart';
import '../../../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../../../domain/usecases/marketplace/product/search_products_use_case.dart';

class ProductsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetProductsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => SearchProductsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ProductsListController(), fenix: true);
  }
}
