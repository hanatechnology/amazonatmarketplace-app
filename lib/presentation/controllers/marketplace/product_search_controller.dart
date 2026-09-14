import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../core/states/app_state.dart';
import '../../../data/services/storage_service.dart';
import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/entities/marketplace/product_entity.dart';
import '../../../domain/entities/marketplace/product_filter.dart';
import '../../../domain/entities/marketplace/product_query.dart';
import '../../../domain/usecases/base_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_category_tree_use_case.dart';
import '../../../domain/usecases/marketplace/product/get_products_page_use_case.dart';

const String kSearchResults = 'search_results';
const String kSearchCategories = 'search_categories';

/// Backs the search screen: one paginated `GET /products` driven by a search
/// term plus a [ProductFilter].
///
/// The screen has two faces. With nothing asked for yet it shows the entry
/// layout — recent searches, the three `featured_section` shortcuts, the
/// category list. As soon as there is a term, a featured section or any filter,
/// it becomes results.
class ProductSearchController
    extends BaseStateController<GetProductsPageUseCase> {
  static const int kPageSize = 20;

  /// Device-local: there is no search-history endpoint.
  static const String _recentKey = 'recent_searches';
  static const int _maxRecent = 8;

  /// The only three values `featured_section` accepts.
  static const List<String> featuredSections = [
    'NEW_ARRIVALS',
    'BEST_SELLERS',
    'ADMIN_PICKS',
  ];

  final searchQuery = ''.obs;
  final currentFilter = const ProductFilter().obs;

  /// Edited by the filter sheet, only committed on apply.
  final tempFilter = const ProductFilter().obs;

  final recentSearches = <String>[].obs;

  final hasMore = false.obs;
  final isLoadingMore = false.obs;

  /// Total across all pages, from the pagination envelope — the count in the
  /// header is the size of the result set, not of the page in hand.
  final totalResults = 0.obs;

  int _page = 1;

  /// Entry layout until the customer has actually asked for something.
  bool get isBrowsing =>
      searchQuery.value.trim().isEmpty && !currentFilter.value.hasActiveFilters;

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

    _loadRecentSearches();
    _loadCategories();
    // Nothing asked for yet means nothing to fetch — the entry layout needs
    // categories, not a page of every product in the marketplace.
    if (!isBrowsing) search();
  }

  /// Top-level categories for the entry list and the filter chips. The tree is
  /// used rather than the flat list so each row can show its subcategory count.
  Future<void> _loadCategories() => handleState<List<CategoryEntity>>(
        kSearchCategories,
        () => Get.find<GetCategoryTreeUseCase>().execute(),
      );

  List<CategoryEntity> get categories =>
      (getOperationData<List<CategoryEntity>>(kSearchCategories) ?? const [])
          .where((category) => category.parentId == null)
          .toList();

  // ── Recent searches (device-local) ────────────────────────
  void _loadRecentSearches() {
    final stored = Get.find<StorageService>().read<List>(_recentKey);
    recentSearches.assignAll(
      (stored ?? const []).map((entry) => entry.toString()).toList(),
    );
  }

  void _rememberSearch(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final next = [
      trimmed,
      ...recentSearches.where((entry) => entry != trimmed),
    ].take(_maxRecent).toList();
    recentSearches.assignAll(next);
    Get.find<StorageService>().write(_recentKey, next);
  }

  void removeRecentSearch(String term) {
    recentSearches.remove(term);
    Get.find<StorageService>().write(_recentKey, recentSearches.toList());
  }

  void clearRecentSearches() {
    recentSearches.clear();
    Get.find<StorageService>().remove(_recentKey);
  }

  // ── Querying ──────────────────────────────────────────────
  /// Called by the search field with an already-debounced term.
  Future<void> onSearchChanged(String query) async {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    if (isBrowsing) return;
    await search();
  }

  /// Called when the customer commits a term (submit, or taps a recent chip).
  Future<void> submitSearch(String query) async {
    searchQuery.value = query;
    _rememberSearch(query);
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
    if (isBrowsing) return;
    search();
  }

  /// Back to the entry layout: term and filters both dropped.
  void clearQuery() {
    searchQuery.value = '';
    currentFilter.value = const ProductFilter();
  }

  void selectFeaturedSection(String section) {
    currentFilter.value = currentFilter.value.copyWith(
      featuredSection: section,
    );
    search();
  }

  void selectCategory(CategoryEntity category) {
    currentFilter.value = currentFilter.value.copyWith(
      categoryId: category.id,
      categoryName: category.name,
    );
    search();
  }

  void removeSort() => applyFilter(
        currentFilter.value.copyWith(sort: ProductSortOption.relevance),
      );

  void removePriceRange() =>
      applyFilter(currentFilter.value.copyWith(clearPriceRange: true));

  void removeCategory() =>
      applyFilter(currentFilter.value.copyWith(clearCategory: true));

  void removeFeaturedSection() =>
      applyFilter(currentFilter.value.copyWith(clearFeatured: true));

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
