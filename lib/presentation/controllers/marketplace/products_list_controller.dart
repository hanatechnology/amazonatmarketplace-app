import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../core/states/app_state.dart';
import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/entities/marketplace/product_entity.dart';
import '../../../domain/entities/marketplace/product_filter.dart';
import '../../../domain/entities/marketplace/product_query.dart';
import '../../../domain/usecases/base_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_category_tree_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';

export '../../../domain/entities/marketplace/product_filter.dart';

/// Products inside one category — or all products, when opened from "See all".
///
/// Every dimension on this screen is a documented `GET /products` parameter:
/// `category_id`, `sortBy`/`sortDirection`, the `filters[gte_/lte_base_price]`
/// pair, and `page`/`limit`. Nothing is filtered client-side.
class ProductsListController
    extends BaseStateController<GetProductsPageUseCase> {
  static const String kProducts = 'products';
  static const String kTree = 'category_tree';
  static const int kPageSize = 20;

  // ── Arguments ──────────────────────────────────────────
  /// null = "See all" (no category filter)
  String? categoryId;
  String? categoryName;

  // ── Filter state ───────────────────────────────────────
  final currentFilter = const ProductFilter().obs;

  /// Edited by the filter sheet, only committed on apply.
  final tempFilter = const ProductFilter().obs;

  /// Single-select rail. Null means the parent category itself.
  final selectedSubcategoryId = Rx<String?>(null);

  final hasMore = false.obs;
  final isLoadingMore = false.obs;

  /// Total across all pages, from the pagination envelope — the count in the
  /// header is the size of the result set, not of the page in hand.
  final totalResults = 0.obs;

  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      categoryId = args['categoryId'] as String?;
      categoryName = args['categoryName'] as String?;
    }
    if (categoryId != null) _loadSubcategories();
    loadProducts();
  }

  /// The category actually queried: a chosen subcategory wins over its parent,
  /// because `category_id` takes exactly one value.
  String? get effectiveCategoryId =>
      selectedSubcategoryId.value ?? categoryId;

  /// Children of this category, from `GET /categories/tree`. Empty for a leaf
  /// category, for "See all", or while the tree is still loading — the rail
  /// simply does not render.
  List<CategoryEntity> get subcategories {
    final tree = getOperationData<List<CategoryEntity>>(kTree) ?? const [];
    final match = _findCategory(tree, categoryId);
    return match?.children ?? const [];
  }

  CategoryEntity? _findCategory(List<CategoryEntity> nodes, String? id) {
    if (id == null) return null;
    for (final node in nodes) {
      if (node.id == id) return node;
      final found = _findCategory(node.children, id);
      if (found != null) return found;
    }
    return null;
  }

  Future<void> _loadSubcategories() => handleState<List<CategoryEntity>>(
        kTree,
        () => Get.find<GetCategoryTreeUseCase>().execute(),
      );

  Future<void> loadProducts() async {
    _page = 1;
    await _fetchPage(append: false);
  }

  @override
  Future<void> refresh() => loadProducts();

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page += 1;
    await _fetchPage(append: true);
    isLoadingMore.value = false;
  }

  void selectSubcategory(String? id) {
    if (selectedSubcategoryId.value == id) return;
    selectedSubcategoryId.value = id;
    loadProducts();
  }

  /// Apply the filter the sheet was editing.
  void applyFilter(ProductFilter filter) {
    currentFilter.value = filter;
    loadProducts();
  }

  void clearFilters() {
    currentFilter.value = const ProductFilter();
    loadProducts();
  }

  void removeSort() => applyFilter(
        currentFilter.value.copyWith(sort: ProductSortOption.relevance),
      );

  void removePriceRange() =>
      applyFilter(currentFilter.value.copyWith(clearPriceRange: true));

  /// Screen title: category name, or nothing for the "see all" view.
  String get pageTitle => categoryName ?? '';

  bool get isCategoryView => categoryId != null;

  Future<void> _fetchPage({required bool append}) async {
    await handlePaginationState<ProductEntity>(
      kProducts,
      () async {
        final state = await useCase.call(
          PaginationInput<ProductQuery>(
            page: _page,
            limit: kPageSize,
            filters: ProductQuery(
              filter: currentFilter.value.copyWith(
                categoryId: effectiveCategoryId,
              ),
            ),
          ),
        );
        return state.when(
          onInitial: () => const AppStateInitial<List<ProductEntity>>(),
          onLoading: () => const AppStateLoading<List<ProductEntity>>(),
          onSuccess: (paged, message) {
            hasMore.value = paged.hasMore;
            totalResults.value = paged.totalItems;
            _page = paged.currentPage;
            return AppStateSuccess(paged.items, message: message);
          },
          onError: (message, code) {
            // Roll the cursor back so a retry re-requests the failed page.
            if (append && _page > 1) _page -= 1;
            return AppStateError<List<ProductEntity>>(message, code: code);
          },
        );
      },
      append: append,
    );
  }

  void openProduct(ProductEntity product) =>
      Get.toNamed(Routes.MARKETPLACE_PRODUCT, arguments: product.id);
}
