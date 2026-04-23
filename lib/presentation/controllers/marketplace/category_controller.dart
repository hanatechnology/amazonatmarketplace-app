import 'package:get/get.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/usecases/marketplace/product/get_categories_use_case.dart';

const String kCategoryProducts = 'categories'; // key kept for compat

class CategoryController extends BaseStateController<GetCategoriesUseCase> {
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() {
    return handleState(
      kCategoryProducts,
      () async => await useCase.execute(),
    );
  }

  Future<void> refreshCategory() => loadCategories();
}
