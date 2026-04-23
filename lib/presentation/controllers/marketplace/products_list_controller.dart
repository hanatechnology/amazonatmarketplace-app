import 'package:get/get.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/usecases/marketplace/product/get_products_use_case.dart';
import '../../../domain/usecases/marketplace/product/search_products_use_case.dart';

/// Sort options for the products list
enum ProductSortOption {
  relevance,
  priceLowHigh,
  priceHighLow,
  rating,
}

/// Active filter state
class ProductFilter {
  final ProductSortOption sort;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  const ProductFilter({
    this.sort = ProductSortOption.relevance,
    this.minPrice,
    this.maxPrice,
    this.minRating,
  });

  bool get hasActiveFilters =>
      sort != ProductSortOption.relevance ||
      minPrice != null ||
      maxPrice != null ||
      minRating != null;

  ProductFilter copyWith({
    ProductSortOption? sort,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool clearPriceRange = false,
    bool clearRating = false,
  }) {
    return ProductFilter(
      sort: sort ?? this.sort,
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
      minRating: clearRating ? null : (minRating ?? this.minRating),
    );
  }
}

class ProductsListController extends BaseStateController<GetProductsUseCase> {
  static const String kProducts = 'products';

  // ── Arguments ──────────────────────────────────────────
  /// null = "See All" (no category filter)
  String? categoryId;
  String? categoryName;

  // ── Search ─────────────────────────────────────────────
  final searchQuery = ''.obs;

  // ── Filter state ───────────────────────────────────────
  final currentFilter = const ProductFilter().obs;

  // ── Temp filter (while bottom sheet is open) ──────────
  final tempFilter = const ProductFilter().obs;

  @override
  void onInit() {
    super.onInit();
    // Read arguments: either a Map with categoryId/name, or null
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      categoryId = args['categoryId'] as String?;
      categoryName = args['categoryName'] as String?;
    }
    loadProducts();
  }

  Future<void> loadProducts() async {
    await handleState(
      kProducts,
      () => useCase.execute(),
      // TODO: When API is ready, pass categoryId + filter to PaginationInput:
      // () => useCase.call(PaginationInput(
      //   page: 1,
      //   filters: {
      //     if (categoryId != null) 'category_id': categoryId!,
      //     if (currentFilter.value.minPrice != null) 'min_price': currentFilter.value.minPrice!,
      //     if (currentFilter.value.maxPrice != null) 'max_price': currentFilter.value.maxPrice!,
      //     if (currentFilter.value.minRating != null) 'min_rating': currentFilter.value.minRating!,
      //     'sort': currentFilter.value.sort.name,
      //   },
      // )),
    );
  }

  Future<void> refresh() => loadProducts();

  /// Called by SearchBarWidget with debounced query
  Future<void> onSearch(String query) async {
    searchQuery.value = query;
    // If empty, reload full list; otherwise search
    if (query.isEmpty) {
      await loadProducts();
    } else {
      await handleState(
        kProducts,
        () => Get.find<SearchProductsUseCase>().call(query),
      );
    }
  }

  /// Apply filter from bottom sheet
  void applyFilter(ProductFilter filter) {
    currentFilter.value = filter;
    loadProducts();
  }

  /// Reset all filters
  void clearFilters() {
    currentFilter.value = const ProductFilter();
    loadProducts();
  }

  /// Screen title: category name or "All Products"
  String get pageTitle => categoryName ?? '';

  bool get isCategoryView => categoryId != null;
}
