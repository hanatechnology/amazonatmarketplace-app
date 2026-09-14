import 'package:get/get.dart';
import '../../../../../data/repositories/product_repository.dart';
import '../../../../../data/services/api_service.dart';
import '../../../../controllers/marketplace/category_controller.dart';
import '../../../../../domain/usecases/marketplace/product/get_category_tree_use_case.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    // Registered here as well as in the shell binding: this route is reachable
    // directly from a notification or a deep link, with no main navigation
    // underneath it to have provided the repository.
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut(() => ProductRepository(Get.find<ApiService>()), fenix: true);
    }
    Get.lazyPut(() => GetCategoryTreeUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);
  }
}
