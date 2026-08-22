import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../core/states/app_state.dart';
import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/entities/marketplace/product_entity.dart';
import '../../../domain/entities/marketplace/product_filter.dart';
import '../../../domain/entities/marketplace/product_query.dart';
import '../../../domain/usecases/base_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';

const String kSearchResults = 'search_results';
const String kSearchCategories = 'search_categories';

/// Backs the search results screen: one paginated `GET /products` driven by a
/// search term plus a [ProductFilter].
class ProductSearchController
    extends BaseStateController<GetProductsPageUseCase> {
  static const int kPageSize = 20;

  final searchQuery = ''.obs;
  final currentFilter = const ProductFilter().obs;

  /// Edited by the filter sheet, only committed on apply.
  final tempFilter = const ProductFilter().obs;

  final hasMore = false.obs;
  final isLoadingMore = false.obs;

  int _page = 1;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      searchQuery.value = (args['query'] as String?) ?? '';
      final categoryId = args['categoryId'] as String?;
      if (categoryId != null) {
        currentFilter.value = currentFilter.value.copyWith(
          categoryId: categoryId,
          categoryName: args['categoryName'] as String?,
        );
      }
    }

    _loadCategories();
    search();
  }

  /// Categories power the category filter chips.
  Future<void> _loadCategories() => handleState<List<CategoryEntity>>(
        kSearchCategories,
        () => Get.find<GetCategoriesUseCase>().execute(),
      );

  List<CategoryEntity> get categories =>
      getOperationData<List<CategoryEntity>>(kSearchCategories) ?? const [];

  /// Called by the search field with an already-debounced term.
  Future<void> onSearchChanged(String query) async {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    await search();
  }

  /// Reload from page 1. Any change to the term or the filter resets paging,
  /// matching the web, which drops `page` whenever either changes.
  Future<void> search() async {
    _page = 1;
    await _fetchPage(append: false);
  }

  Future<void> refreshResults() => search();

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page += 1;
    await _fetchPage(append: true);
    isLoadingMore.value = false;
  }

  void applyFilter(ProductFilter filter) {
    currentFilter.value = filter;
    search();
  }

  void clearFilters() {
    currentFilter.value = const ProductFilter();
    search();
  }

  void removeSort() =>
      applyFilter(currentFilter.value.copyWith(sort: ProductSortOption.relevance));

  void removePriceRange() =>
      applyFilter(currentFilter.value.copyWith(clearPriceRange: true));

  void removeCategory() =>
      applyFilter(currentFilter.value.copyWith(clearCategory: true));

  Future<void> _fetchPage({required bool append}) async {
    await handlePaginationState<ProductEntity>(
      kSearchResults,
      () async {
        final state = await useCase.call(
          PaginationInput<ProductQuery>(
            page: _page,
            limit: kPageSize,
            filters: ProductQuery(
              search: searchQuery.value.isEmpty ? null : searchQuery.value,
              filter: currentFilter.value,
            ),
          ),
        );
        return state.when(
          onInitial: () => const AppStateInitial<List<ProductEntity>>(),
          onLoading: () => const AppStateLoading<List<ProductEntity>>(),
          onSuccess: (paged, message) {
            hasMore.value = paged.hasMore;
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
