import 'package:get/get.dart';
import '../../../../controllers/marketplace/category_controller.dart';
import '../../../../../domain/usecases/marketplace/product/get_categories_use_case.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetCategoriesUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CategoryController(), fenix: true);
  }
}
