
import '../../../app/routes/app_routes.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/usecases/marketplace/product/get_category_tree_use_case.dart';
import 'package:marketplace/app/routes/app_router.dart';

const String kCategoryProducts = 'categories'; // key kept for compat

/// The Categories tab.
///
/// Reads `GET /categories/tree` rather than the flat list: the tile's
/// subcategory count and the rail on the products screen both come from
/// `children`, which the flat endpoint does not return.
class CategoryController extends BaseStateController<GetCategoryTreeUseCase> {
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() {
    return handleState<List<CategoryEntity>>(
      kCategoryProducts,
      () => useCase.execute(),
    );
  }

  Future<void> refreshCategory() => loadCategories();

  /// Top-level categories only — a child is reached through its parent.
  List<CategoryEntity> get topLevel {
    final all =
        getOperationData<List<CategoryEntity>>(kCategoryProducts) ?? const [];
    // The tree endpoint already returns roots, but a flat payload would not,
    // so children are filtered out defensively rather than assumed absent.
    return all.where((category) => category.parentId == null).toList();
  }

  void openCategory(CategoryEntity category) {
    AppRouter.toNamed(
      Routes.MARKETPLACE_PRODUCTS_LIST,
      arguments: <String, dynamic>{
        'categoryId': category.id,
        'categoryName': category.name,
      },
    );
  }
}
