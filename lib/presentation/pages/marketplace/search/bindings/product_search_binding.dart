import 'package:get/get.dart';
import '../../../../../data/repositories/product_repository.dart';
import '../../../../../data/services/api_service.dart';
import '../../../../controllers/marketplace/product_search_controller.dart';
import '../../../../../domain/usecases/marketplace/product/get_category_tree_use_case.dart';
import '../../../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';

class ProductSearchBinding extends Bindings {
  @override
  void dependencies() {
    // Registered here as well as in the shell binding: this route is reachable
    // directly from a notification or a deep link, with no main navigation
    // underneath it to have provided the repository.
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut(() => ProductRepository(Get.find<ApiService>()), fenix: true);
    }
    Get.lazyPut(() => GetProductsPageUseCase(Get.find()));
    // The entry list shows a subcategory count per row, which only the tree has.
    Get.lazyPut(() => GetCategoryTreeUseCase(Get.find()));
    Get.lazyPut(() => ProductSearchController());
  }
}
