import 'package:get/get.dart';
import '../../../../controllers/marketplace/product_search_controller.dart';
import '../../../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';
import '../../../../../domain/usecases/marketplace/product/get_categories_use_case.dart';

class ProductSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetProductsPageUseCase(Get.find()));
    Get.lazyPut(() => GetCategoriesUseCase(Get.find()));
    Get.lazyPut(() => ProductSearchController());
  }
}
