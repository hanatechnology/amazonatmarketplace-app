import 'package:get/get.dart';
import '../../../../controllers/marketplace/home_controller.dart';
import '../../../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../../../domain/usecases/marketplace/product/search_products_use_case.dart';
import '../../../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetCategoriesUseCase(Get.find()));
    Get.lazyPut(() => SearchProductsUseCase(Get.find()));
    Get.lazyPut(() => GetProductsPageUseCase(Get.find()));
    Get.lazyPut(() => HomeController());
  }
}
