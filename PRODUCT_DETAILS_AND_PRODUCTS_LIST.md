# Product Details & Products List — Implementation Guide

> **IMPORTANT**: Coding agent instruction document. Follow every spec literally.
> All patterns use the existing `AppState<T>` + `BaseStateController` + `BaseUseCase` architecture.
>
> **Figma nodes**: Product Details `112:687` · Category/Products List `110:186`
> **File key**: `NO3iZ9gUb03kQWQELYob7F`

---

## Table of Contents

1. [New Translation Keys](#1-new-translation-keys)
2. [New Routes](#2-new-routes)
3. [Products List — Controller & Binding](#3-products-list--controller--binding)
4. [Products List — Page (Category filter + All Products + Search + Filter)](#4-products-list--page)
5. [Filter Bottom Sheet Widget](#5-filter-bottom-sheet-widget)
6. [Product Details — Controller Update](#6-product-details--controller-update)
7. [Product Details — Page (Full Implementation)](#7-product-details--page)
8. [Update Home Screen — Wire Taps](#8-update-home-screen--wire-taps)
9. [Update Category Page — Show Category Grid](#9-update-category-page--show-category-grid)
10. [Update `app_pages.dart` — Add New Route](#10-update-app_pagesdart--add-new-route)
11. [New Locale Keys to Add](#11-new-locale-keys-to-add)
12. [Files Modified Summary](#12-files-modified-summary)

---

## 1. New Translation Keys

### Add to `lib/core/localization/locale_keys.dart` (inside the class body):

```dart
  // ── Products List / Filter ────────────────────────────
  static const String allProducts = 'all_products';
  static const String productsFound = 'products_found';
  static const String filterTitle = 'filter_title';
  static const String clearAll = 'clear_all';
  static const String applyFilters = 'apply_filters';
  static const String sortBy = 'sort_by';
  static const String sortRelevance = 'sort_relevance';
  static const String sortPriceLowHigh = 'sort_price_low_high';
  static const String sortPriceHighLow = 'sort_price_high_low';
  static const String sortRating = 'sort_rating';
  static const String priceRange = 'price_range';
  static const String minRating = 'min_rating';
  static const String andAbove = 'and_above';
  static const String noProducts = 'no_products';
  static const String noProductsMessage = 'no_products_message';
  static const String allFilter = 'all_filter';

  // ── Product Details ───────────────────────────────────
  static const String quantity = 'quantity';
  static const String inStock = 'in_stock';
  static const String outOfStock = 'out_of_stock';
  static const String seeAllReviews = 'see_all_reviews';
  static const String viewAllSellers = 'view_all_sellers';
  static const String shareProduct = 'share_product';
  static const String addedToCart = 'added_to_cart';
```

### Add to `lib/core/localization/en.dart`:

```dart
  // ── Products List / Filter ────────────────────────────
  'all_products': 'All Products',
  'products_found': '@count Products',
  'filter_title': 'Filter',
  'clear_all': 'Clear All',
  'apply_filters': 'Apply Filters',
  'sort_by': 'Sort By',
  'sort_relevance': 'Relevance',
  'sort_price_low_high': 'Price: Low to High',
  'sort_price_high_low': 'Price: High to Low',
  'sort_rating': 'Highest Rating',
  'price_range': 'Price Range',
  'min_rating': 'Minimum Rating',
  'and_above': '& above',
  'no_products': 'No Products Found',
  'no_products_message': 'Try adjusting your filters or search term',
  'all_filter': 'All',

  // ── Product Details ───────────────────────────────────
  'quantity': 'Quantity',
  'in_stock': 'In Stock',
  'out_of_stock': 'Out of Stock',
  'see_all_reviews': 'See All Reviews',
  'view_all_sellers': 'View All Sellers',
  'share_product': 'Share',
  'added_to_cart': 'Added to cart!',
```

### Add to `lib/core/localization/ar.dart`:

```dart
  // ── Products List / Filter ────────────────────────────
  'all_products': 'جميع المنتجات',
  'products_found': '@count منتج',
  'filter_title': 'تصفية',
  'clear_all': 'مسح الكل',
  'apply_filters': 'تطبيق التصفية',
  'sort_by': 'ترتيب حسب',
  'sort_relevance': 'الأكثر صلة',
  'sort_price_low_high': 'السعر: من الأقل',
  'sort_price_high_low': 'السعر: من الأعلى',
  'sort_rating': 'الأعلى تقييماً',
  'price_range': 'نطاق السعر',
  'min_rating': 'الحد الأدنى للتقييم',
  'and_above': 'وأعلى',
  'no_products': 'لا توجد منتجات',
  'no_products_message': 'جرب تعديل الفلاتر أو مصطلح البحث',
  'all_filter': 'الكل',

  // ── Product Details ───────────────────────────────────
  'quantity': 'الكمية',
  'in_stock': 'متوفر',
  'out_of_stock': 'غير متوفر',
  'see_all_reviews': 'عرض جميع التقييمات',
  'view_all_sellers': 'عرض جميع البائعين',
  'share_product': 'مشاركة',
  'added_to_cart': 'تمت الإضافة إلى السلة!',
```

---

## 2. New Routes

### Add to `lib/app/routes/app_routes.dart` (inside the `Routes` class):

```dart
  // Products list — handles both "See All" and category-filtered views
  static const String MARKETPLACE_PRODUCTS_LIST = '/marketplace/products-list';
```

---

## 3. Products List — Controller & Binding

### 3.1 Create `lib/presentation/controllers/marketplace/products_list_controller.dart`

This controller handles:
- Category-filtered view (when `categoryId` is passed via `Get.arguments`)
- All-products view (when no `categoryId`)
- Search with debounce
- Sort + filter options

```dart
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
```

### 3.2 Create `lib/presentation/pages/marketplace/category/bindings/products_list_binding.dart`

```dart
import 'package:get/get.dart';
import '../../../../controllers/marketplace/products_list_controller.dart';
import '../../../../../domain/usecases/marketplace/product/search_products_use_case.dart';

class ProductsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchProductsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ProductsListController(), fenix: true);
  }
}
```

---

## 4. Products List — Page

### Create `lib/presentation/pages/marketplace/category/products_list_page.dart`

**Figma**: Node `110:186` — Category screen with search + filter chips + product grid

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/components/marketplace/search_bar_widget.dart';
import '../../../../core/components/marketplace/product_card.dart';
import '../../../../core/components/marketplace/loading_shimmer.dart';
import '../../../controllers/marketplace/products_list_controller.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../app/routes/app_routes.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductsListController>();

    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(
        title: controller.pageTitle.isEmpty
            ? LocaleKeys.allProducts.tr
            : controller.pageTitle,
        actions: [
          // Share icon (product list share is optional)
          Obx(() => controller.currentFilter.value.hasActiveFilters
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: GestureDetector(
                      onTap: controller.clearFilters,
                      child: Text(
                        LocaleKeys.clearAll.tr,
                        style: MarketplaceTypography.cardTitle.copyWith(
                          color: MarketplaceColors.primary,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        color: MarketplaceColors.primary,
        child: CustomScrollView(
          slivers: [

            // ── Search Bar ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  MarketplaceSpacing.screenPaddingH,
                  MarketplaceSpacing.md,
                  MarketplaceSpacing.screenPaddingH,
                  MarketplaceSpacing.sm,
                ),
                child: SearchBarWidget(
                  hintText: LocaleKeys.searchProducts.tr,
                  onSearch: controller.onSearch,
                  onFilter: () => _showFilterBottomSheet(context, controller),
                ),
              ),
            ),

            // ── Active Filter Chips ───────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                final filter = controller.currentFilter.value;
                if (!filter.hasActiveFilters) return const SizedBox.shrink();
                return _ActiveFilterChips(
                  filter: filter,
                  onRemoveSort: () => controller.applyFilter(
                    filter.copyWith(sort: ProductSortOption.relevance),
                  ),
                  onRemovePrice: () => controller.applyFilter(
                    filter.copyWith(clearPriceRange: true),
                  ),
                  onRemoveRating: () => controller.applyFilter(
                    filter.copyWith(clearRating: true),
                  ),
                );
              }),
            ),

            // ── Results count ─────────────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                final state = controller.stateFor(ProductsListController.kProducts);
                return state.value.when(
                  onInitial: () => const SizedBox.shrink(),
                  onLoading: () => const SizedBox.shrink(),
                  onSuccess: (data, _) {
                    final count = (data as List).length;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MarketplaceSpacing.screenPaddingH,
                        MarketplaceSpacing.sm,
                        MarketplaceSpacing.screenPaddingH,
                        MarketplaceSpacing.sm,
                      ),
                      child: Text(
                        LocaleKeys.productsFound.trParams({
                          'count': '$count',
                        }),
                        style: MarketplaceTypography.cardSubtitle,
                      ),
                    );
                  },
                  onError: (_, __) => const SizedBox.shrink(),
                );
              }),
            ),

            // ── Product Grid ──────────────────────────────
            _buildProductGrid(controller),

            // ── Bottom spacing ────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: MarketplaceSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductsListController controller) {
    return Obx(() {
      final state = controller.stateFor(ProductsListController.kProducts);
      return state.value.when(
        onInitial: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
        onLoading: () => SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          sliver: SliverGrid.count(
            crossAxisCount: MarketplaceSpacing.productGridColumns,
            crossAxisSpacing: MarketplaceSpacing.productGridGap,
            mainAxisSpacing: MarketplaceSpacing.productGridGap,
            childAspectRatio: MarketplaceSpacing.productCardWidth /
                MarketplaceSpacing.productCardHeight,
            children: List.generate(6, (_) => const ProductCardShimmer()),
          ),
        ),
        onSuccess: (data, _) {
          final products = data as List<ProductEntity>;

          if (products.isEmpty) {
            return SliverFillRemaining(
              child: _EmptyProductsView(
                onClear: controller.currentFilter.value.hasActiveFilters
                    ? controller.clearFilters
                    : null,
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
            ),
            sliver: SliverGrid.count(
              crossAxisCount: MarketplaceSpacing.productGridColumns,
              crossAxisSpacing: MarketplaceSpacing.productGridGap,
              mainAxisSpacing: MarketplaceSpacing.productGridGap,
              childAspectRatio: MarketplaceSpacing.productCardWidth /
                  MarketplaceSpacing.productCardHeight,
              children: products
                  .map((product) => ProductCard(
                        imageUrl: product.imageUrl,
                        name: product.name,
                        sellerName: product.sellerName,
                        price: product.price,
                        rating: product.rating,
                        originalPrice: product.originalPrice,
                        discountPercent: product.discountPercent,
                        onTap: () => Get.toNamed(
                          Routes.MARKETPLACE_PRODUCT,
                          arguments: product.id,
                        ),
                        onAddToCart: () {
                          // TODO: Call CartController.addToCart(product.id)
                        },
                      ))
                  .toList(),
            ),
          );
        },
        onError: (message, _) => SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: MarketplaceColors.textSecondary,
                ),
                const SizedBox(height: MarketplaceSpacing.md),
                Text(
                  message ?? LocaleKeys.error.tr,
                  style: MarketplaceTypography.descriptionBody,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MarketplaceSpacing.md),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: Text(LocaleKeys.retry.tr),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showFilterBottomSheet(
    BuildContext context,
    ProductsListController controller,
  ) {
    // Initialize temp filter with current
    controller.tempFilter.value = controller.currentFilter.value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFilterBottomSheet(controller: controller),
    );
  }
}

// ── Active Filter Chips ──────────────────────────────────

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({
    required this.filter,
    required this.onRemoveSort,
    required this.onRemovePrice,
    required this.onRemoveRating,
  });

  final ProductFilter filter;
  final VoidCallback onRemoveSort;
  final VoidCallback onRemovePrice;
  final VoidCallback onRemoveRating;

  String _sortLabel(ProductSortOption sort) {
    switch (sort) {
      case ProductSortOption.priceLowHigh:
        return LocaleKeys.sortPriceLowHigh.tr;
      case ProductSortOption.priceHighLow:
        return LocaleKeys.sortPriceHighLow.tr;
      case ProductSortOption.rating:
        return LocaleKeys.sortRating.tr;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH,
        ),
        children: [
          if (filter.sort != ProductSortOption.relevance)
            _FilterChip(
              label: _sortLabel(filter.sort),
              onRemove: onRemoveSort,
            ),
          if (filter.minPrice != null || filter.maxPrice != null)
            _FilterChip(
              label:
                  '\$${filter.minPrice?.toInt() ?? 0} – \$${filter.maxPrice?.toInt() ?? '∞'}',
              onRemove: onRemovePrice,
            ),
          if (filter.minRating != null)
            _FilterChip(
              label:
                  '${filter.minRating!.toInt()}★ ${LocaleKeys.andAbove.tr}',
              onRemove: onRemoveRating,
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MarketplaceColors.secondary,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: MarketplaceColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: MarketplaceTypography.micro.copyWith(
              color: MarketplaceColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: MarketplaceColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────

class _EmptyProductsView extends StatelessWidget {
  const _EmptyProductsView({this.onClear});
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: MarketplaceColors.secondary.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: MarketplaceColors.primary,
          ),
        ),
        const SizedBox(height: MarketplaceSpacing.md),
        Text(
          LocaleKeys.noProducts.tr,
          style: MarketplaceTypography.sectionHeading,
        ),
        const SizedBox(height: MarketplaceSpacing.sm),
        Text(
          LocaleKeys.noProductsMessage.tr,
          style: MarketplaceTypography.descriptionBody,
          textAlign: TextAlign.center,
        ),
        if (onClear != null) ...[
          const SizedBox(height: MarketplaceSpacing.lg),
          OutlinedButton(
            onPressed: onClear,
            child: Text(LocaleKeys.clearAll.tr),
          ),
        ],
      ],
    );
  }
}
```

---

## 5. Filter Bottom Sheet Widget

### Create `lib/core/components/marketplace/product_filter_bottom_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../localization/locale_keys.dart';
import '../../../presentation/controllers/marketplace/products_list_controller.dart';

class ProductFilterBottomSheet extends StatelessWidget {
  const ProductFilterBottomSheet({super.key, required this.controller});

  final ProductsListController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: MarketplaceColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MarketplaceRadius.bottomNav),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ───────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: MarketplaceColors.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.md),

          // ── Header ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.filterTitle.tr,
                  style: MarketplaceTypography.sectionHeading,
                ),
                TextButton(
                  onPressed: () {
                    controller.tempFilter.value = const ProductFilter();
                  },
                  child: Text(
                    LocaleKeys.clearAll.tr,
                    style: MarketplaceTypography.cardTitle.copyWith(
                      color: MarketplaceColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: MarketplaceColors.stroke, height: 1),

          // ── Scrollable content ────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
              child: Obx(() {
                final temp = controller.tempFilter.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Sort By ─────────────────────────
                    Text(
                      LocaleKeys.sortBy.tr,
                      style: MarketplaceTypography.sectionSubheading,
                    ),
                    const SizedBox(height: MarketplaceSpacing.sm),
                    ...[
                      (ProductSortOption.relevance, LocaleKeys.sortRelevance.tr),
                      (ProductSortOption.priceLowHigh, LocaleKeys.sortPriceLowHigh.tr),
                      (ProductSortOption.priceHighLow, LocaleKeys.sortPriceHighLow.tr),
                      (ProductSortOption.rating, LocaleKeys.sortRating.tr),
                    ].map((option) => _SortOptionTile(
                          label: option.$2,
                          isSelected: temp.sort == option.$1,
                          onTap: () {
                            controller.tempFilter.value =
                                temp.copyWith(sort: option.$1);
                          },
                        )),

                    const SizedBox(height: MarketplaceSpacing.lg),
                    const Divider(color: MarketplaceColors.stroke),
                    const SizedBox(height: MarketplaceSpacing.lg),

                    // ── Price Range ─────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleKeys.priceRange.tr,
                          style: MarketplaceTypography.sectionSubheading,
                        ),
                        Text(
                          '\$${(temp.minPrice ?? 0).toInt()} – \$${(temp.maxPrice ?? 500).toInt()}',
                          style: MarketplaceTypography.cardTitle.copyWith(
                            color: MarketplaceColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MarketplaceSpacing.sm),
                    RangeSlider(
                      values: RangeValues(
                        temp.minPrice ?? 0,
                        temp.maxPrice ?? 500,
                      ),
                      min: 0,
                      max: 500,
                      divisions: 50,
                      activeColor: MarketplaceColors.primary,
                      inactiveColor: MarketplaceColors.stroke,
                      onChanged: (range) {
                        controller.tempFilter.value = temp.copyWith(
                          minPrice: range.start,
                          maxPrice: range.end,
                        );
                      },
                    ),

                    const SizedBox(height: MarketplaceSpacing.lg),
                    const Divider(color: MarketplaceColors.stroke),
                    const SizedBox(height: MarketplaceSpacing.lg),

                    // ── Minimum Rating ──────────────────
                    Text(
                      LocaleKeys.minRating.tr,
                      style: MarketplaceTypography.sectionSubheading,
                    ),
                    const SizedBox(height: MarketplaceSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [1, 2, 3, 4].map((stars) {
                        final isSelected = temp.minRating == stars.toDouble();
                        return GestureDetector(
                          onTap: () {
                            controller.tempFilter.value = isSelected
                                ? temp.copyWith(clearRating: true)
                                : temp.copyWith(minRating: stars.toDouble());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? MarketplaceColors.primary
                                  : MarketplaceColors.surface,
                              borderRadius: BorderRadius.circular(
                                  MarketplaceRadius.smallButton),
                              border: Border.all(
                                color: isSelected
                                    ? MarketplaceColors.primary
                                    : MarketplaceColors.stroke,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: isSelected
                                      ? MarketplaceColors.onPrimary
                                      : MarketplaceColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$stars+ ',
                                  style: MarketplaceTypography.cardTitle.copyWith(
                                    color: isSelected
                                        ? MarketplaceColors.onPrimary
                                        : MarketplaceColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: MarketplaceSpacing.xl),
                  ],
                );
              }),
            ),
          ),

          // ── Apply Button ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MarketplaceSpacing.screenPaddingH,
              0,
              MarketplaceSpacing.screenPaddingH,
              MarketplaceSpacing.lg,
            ),
            child: ElevatedButton(
              onPressed: () {
                controller.applyFilter(controller.tempFilter.value);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  MarketplaceSpacing.buttonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                ),
              ),
              child: Text(
                LocaleKeys.applyFilters.tr,
                style: MarketplaceTypography.buttonLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? MarketplaceColors.primary
                      : MarketplaceColors.stroke,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: MarketplaceColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: MarketplaceSpacing.md),
            Text(
              label,
              style: MarketplaceTypography.body.copyWith(
                color: isSelected
                    ? MarketplaceColors.primary
                    : MarketplaceColors.textBody,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. Product Details — Controller Update

### **REWRITE** `lib/presentation/controllers/marketplace/product_details_controller.dart`

```dart
import 'package:get/get.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/usecases/marketplace/product/get_product_details_use_case.dart';
import '../../../domain/entities/marketplace/product_entity.dart';

class ProductDetailsController
    extends BaseStateController<GetProductDetailsUseCase> {
  // ── Operation keys ──────────────────────────────────────
  static const String kProduct = 'product';

  // ── Arguments ───────────────────────────────────────────
  late String productId;

  // ── Local reactive state ────────────────────────────────
  final quantity = 1.obs;
  final activeImageIndex = 0.obs;
  final isDescriptionExpanded = false.obs;
  final isAddingToCart = false.obs;

  @override
  void onInit() {
    super.onInit();
    productId = Get.arguments as String? ?? '';
    if (productId.isNotEmpty) loadProduct();
  }

  Future<void> loadProduct() async {
    await handleState(kProduct, () => useCase.call(productId));
  }

  Future<void> refresh() => loadProduct();

  // ── Quantity ─────────────────────────────────────────────
  void increment() => quantity.value++;
  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  void onImageChanged(int index) => activeImageIndex.value = index;

  void toggleDescription() =>
      isDescriptionExpanded.value = !isDescriptionExpanded.value;

  // ── Add to cart ───────────────────────────────────────────
  Future<void> addToCart() async {
    if (isAddingToCart.value) return;
    isAddingToCart.value = true;
    try {
      // TODO: Call AddToCartUseCase with productId + quantity
      // await Get.find<AddToCartUseCase>().call(
      //   AddToCartInput(productId: productId, quantity: quantity.value),
      // );
      await Future.delayed(const Duration(milliseconds: 600));
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.BOTTOM,
        messageText: Text(
          'added_to_cart'.tr, // LocaleKeys.addedToCart.tr
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    } finally {
      isAddingToCart.value = false;
    }
  }

  /// Navigate to product's reviews page
  void goToReviews() {
    Get.toNamed('/marketplace/reviews', arguments: productId);
  }

  /// Navigate to all sellers offering this product
  void goToProductSellers() {
    Get.toNamed('/marketplace/product-sellers', arguments: productId);
  }
}
```

---

## 7. Product Details — Page (Full Implementation)

### **REWRITE** `lib/presentation/pages/marketplace/product/product_details_page.dart`

**Figma layout** (node `112:687`) — top to bottom:
```
AppBar: ← "Details"
────────────────────────────────
Image gallery: full-width, 314px, borderRadius 32, swipeable (PageView)
Dot indicator (SmoothPageIndicator)
────────────────────────────────
[padding: 16px horizontal]
Product name (24px SemiBold textBody)
Price row: $X.XX  ~~originalPrice~~  [DiscountBadge]
StarRating (size 24) + "4.2  (120 reviews)"
────────────────────────────────
SellerInfoCard (full width)
────────────────────────────────
"Quantity" label + QuantityStepper (bordered)
────────────────────────────────
"Description" heading + body text (3 lines + expand)
────────────────────────────────
"Reviews & Rating" heading + 2 ReviewItems + "See All Reviews →"
────────────────────────────────
[sticky bottom] "Add To Cart" button (full-width 48px)
```

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/discount_badge.dart';
import '../../../../core/components/marketplace/star_rating.dart';
import '../../../../core/components/marketplace/seller_info_card.dart';
import '../../../../core/components/marketplace/quantity_stepper.dart';
import '../../../../core/components/marketplace/review_item.dart';
import '../../../controllers/marketplace/product_details_controller.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../domain/entities/marketplace/review_entity.dart';
import '../../../../domain/entities/marketplace/seller_entity.dart';

class ProductDetailsPage extends GetView<ProductDetailsController> {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(
        title: LocaleKeys.details.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            color: MarketplaceColors.primary,
            onPressed: () {
              // TODO: Share product URL
            },
          ),
        ],
      ),
      body: Obx(() {
        final state = controller.stateFor(ProductDetailsController.kProduct);
        return state.value.when(
          onInitial: () => const SizedBox.shrink(),
          onLoading: () => const Center(
            child: CircularProgressIndicator(
              color: MarketplaceColors.primary,
            ),
          ),
          onSuccess: (data, _) =>
              _ProductDetailsContent(product: data as ProductEntity),
          onError: (message, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message ?? LocaleKeys.error.tr,
                  style: MarketplaceTypography.descriptionBody,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MarketplaceSpacing.md),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: Text(LocaleKeys.retry.tr),
                ),
              ],
            ),
          ),
        );
      }),
      // ── Sticky Add to Cart bar ──────────────────────────
      bottomNavigationBar: _AddToCartBar(),
    );
  }
}

// ── Main content (shown when product loads) ──────────────

class _ProductDetailsContent extends GetView<ProductDetailsController> {
  const _ProductDetailsContent({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final imagePageController = PageController();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Image Gallery ─────────────────────────────
          _ImageGallery(
            imageUrls: product.imageUrls.isNotEmpty
                ? product.imageUrls
                : [product.imageUrl],
            pageController: imagePageController,
          ),

          // ── Product Info ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
              vertical: MarketplaceSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Product name
                Text(
                  product.name,
                  style: MarketplaceTypography.productTitle,
                ),
                const SizedBox(height: MarketplaceSpacing.sm),

                // Price row
                _PriceRow(product: product),
                const SizedBox(height: MarketplaceSpacing.sm),

                // Rating row
                _RatingRow(product: product),
                const SizedBox(height: MarketplaceSpacing.lg),

                // Seller info card
                _SellerSection(sellerId: product.sellerId),
                const SizedBox(height: MarketplaceSpacing.lg),

                // Quantity
                _QuantitySection(),
                const SizedBox(height: MarketplaceSpacing.lg),

                const Divider(color: MarketplaceColors.stroke),
                const SizedBox(height: MarketplaceSpacing.md),

                // Description
                _DescriptionSection(description: product.description),
                const SizedBox(height: MarketplaceSpacing.lg),

                const Divider(color: MarketplaceColors.stroke),
                const SizedBox(height: MarketplaceSpacing.md),

                // Reviews
                _ReviewsSection(),

                const SizedBox(height: MarketplaceSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image Gallery ────────────────────────────────────────

class _ImageGallery extends GetView<ProductDetailsController> {
  const _ImageGallery({
    required this.imageUrls,
    required this.pageController,
  });

  final List<String> imageUrls;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image PageView
        SizedBox(
          height: MarketplaceSpacing.detailImageHeight,
          child: PageView.builder(
            controller: pageController,
            itemCount: imageUrls.length,
            onPageChanged: controller.onImageChanged,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MarketplaceSpacing.screenPaddingH,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(MarketplaceRadius.detailImage),
                child: AppNetworkImage(
                  imageUrl: imageUrls[index],
                  width: double.infinity,
                  height: MarketplaceSpacing.detailImageHeight,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),

        // Dot indicator
        if (imageUrls.length > 1) ...[
          const SizedBox(height: MarketplaceSpacing.sm),
          Obx(() => SmoothPageIndicator(
            controller: pageController,
            count: imageUrls.length,
            effect: ExpandingDotsEffect(
              activeDotColor: MarketplaceColors.primary,
              dotColor: MarketplaceColors.stroke,
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 3,
            ),
          )),
        ],
        const SizedBox(height: MarketplaceSpacing.sm),
      ],
    );
  }
}

// ── Price Row ────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        // Current price
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: MarketplaceTypography.priceTitle,
        ),
        // Original price (strikethrough)
        if (product.originalPrice != null)
          Text(
            '\$${product.originalPrice!.toStringAsFixed(2)}',
            style: MarketplaceTypography.priceStrikethrough,
          ),
        // Discount badge
        if (product.discountPercent != null)
          DiscountBadge(percentage: product.discountPercent!),
      ],
    );
  }
}

// ── Rating Row ───────────────────────────────────────────

class _RatingRow extends GetView<ProductDetailsController> {
  const _RatingRow({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.goToReviews,
      child: Row(
        children: [
          StarRating(
            rating: product.rating,
            size: 20,
            showLabel: true,
          ),
          const SizedBox(width: 8),
          Text(
            '(${(product.rating * 20).round()} ${LocaleKeys.reviews.tr})',
            style: MarketplaceTypography.descriptionBody.copyWith(
              color: MarketplaceColors.link,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seller Section ───────────────────────────────────────

class _SellerSection extends GetView<ProductDetailsController> {
  const _SellerSection({required this.sellerId});
  final String sellerId;

  @override
  Widget build(BuildContext context) {
    // TODO: When seller details use case is wired up, load seller by sellerId
    // For now, show a placeholder SellerInfoCard with mock data
    final mockSeller = SellerEntity(
      id: sellerId,
      name: 'Seller Name',
      imageUrl: '',
      rating: 4.5,
      isVerified: true,
      isOpen: true,
      followerCount: 1200,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.seller.tr,
              style: MarketplaceTypography.sectionHeading,
            ),
            GestureDetector(
              onTap: controller.goToProductSellers,
              child: Text(
                LocaleKeys.allSellers.tr,
                style: MarketplaceTypography.seeAll,
              ),
            ),
          ],
        ),
        const SizedBox(height: MarketplaceSpacing.sm),
        SellerInfoCard(
          seller: mockSeller,
          onFollow: () {
            // TODO: Follow seller
          },
        ),
      ],
    );
  }
}

// ── Quantity Section ─────────────────────────────────────

class _QuantitySection extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKeys.quantity.tr,
          style: MarketplaceTypography.sectionSubheading,
        ),
        Obx(() => QuantityStepper(
          value: controller.quantity.value,
          onChanged: (val) {
            if (val > controller.quantity.value) {
              controller.increment();
            } else {
              controller.decrement();
            }
          },
          variant: QuantityStepperVariant.bordered,
        )),
      ],
    );
  }
}

// ── Description Section ──────────────────────────────────

class _DescriptionSection extends GetView<ProductDetailsController> {
  const _DescriptionSection({required this.description});
  final String? description;

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.description.tr,
          style: MarketplaceTypography.sectionHeading,
        ),
        const SizedBox(height: MarketplaceSpacing.sm),
        Obx(() {
          final expanded = controller.isDescriptionExpanded.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description!,
                style: MarketplaceTypography.descriptionBody,
                maxLines: expanded ? null : 3,
                overflow: expanded ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: controller.toggleDescription,
                child: Text(
                  expanded ? 'Show less' : LocaleKeys.learnMore.tr,
                  style: MarketplaceTypography.micro.copyWith(
                    color: MarketplaceColors.link,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ── Reviews Section ──────────────────────────────────────

class _ReviewsSection extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    // TODO: Replace mock data with real reviews from ReviewsController
    final mockReviews = [
      ReviewEntity(
        id: '1',
        userName: 'Ahmed M.',
        avatarUrl: '',
        rating: 5,
        text: 'Excellent product! Great quality and fast shipping.',
        createdAt: DateTime.now(),
      ),
      ReviewEntity(
        id: '2',
        userName: 'Sara K.',
        avatarUrl: '',
        rating: 4,
        text: 'Good value for money. Would recommend to others.',
        createdAt: DateTime.now(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.reviewsAndRating.tr,
              style: MarketplaceTypography.sectionHeading,
            ),
            GestureDetector(
              onTap: controller.goToReviews,
              child: Text(
                LocaleKeys.seeAllReviews.tr,
                style: MarketplaceTypography.seeAll,
              ),
            ),
          ],
        ),
        const SizedBox(height: MarketplaceSpacing.md),
        ...mockReviews.map((review) => Padding(
          padding: const EdgeInsets.only(bottom: MarketplaceSpacing.md),
          child: ReviewItem(review: review),
        )),
      ],
    );
  }
}

// ── Sticky Add To Cart Bar ────────────────────────────────

class _AddToCartBar extends GetView<ProductDetailsController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH,
          vertical: MarketplaceSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: MarketplaceColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() => ElevatedButton(
          onPressed: controller.isAddingToCart.value
              ? null
              : controller.addToCart,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              MarketplaceSpacing.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MarketplaceRadius.button),
            ),
            disabledBackgroundColor: MarketplaceColors.primary.withOpacity(0.6),
          ),
          child: controller.isAddingToCart.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MarketplaceColors.onPrimary,
                  ),
                )
              : Text(
                  LocaleKeys.addToCart.tr,
                  style: MarketplaceTypography.buttonLabel,
                ),
        )),
      ),
    );
  }
}
```

---

## 8. Update Home Screen — Wire Taps

### **MODIFY** `lib/presentation/pages/marketplace/home/home_page.dart`

**Change 1**: Category chip `onTap` — navigate to `ProductsListPage` with `categoryId`:

```dart
// In _buildCategoryList() > onSuccess > itemBuilder:
// Replace the onTap: () { setState... } block with:
onTap: () {
  setState(() => _selectedCategoryId = categories[index].id);
  Get.toNamed(
    Routes.MARKETPLACE_PRODUCTS_LIST,
    arguments: {
      'categoryId': categories[index].id,
      'categoryName': categories[index].name,
    },
  );
},
```

**Change 2**: "See All" for Popular Products — navigate to `ProductsListPage` without filter:

```dart
// In build() > Popular Products _SectionHeader:
// Replace the onSeeAll: () { } with:
onSeeAll: () => Get.toNamed(Routes.MARKETPLACE_PRODUCTS_LIST),
```

---

## 9. Update Category Page — Show Category Grid

### **REWRITE** `lib/presentation/pages/marketplace/category/category_page.dart`

The bottom-nav "Category" tab shows a grid of all categories. Tapping one navigates to `ProductsListPage` with that `categoryId`.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/loading_shimmer.dart';
import '../../../controllers/marketplace/category_controller.dart';
import '../../../../domain/entities/marketplace/category_entity.dart';
import '../../../../app/routes/app_routes.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: AppBar(
        title: Text(
          LocaleKeys.allCategories.tr,
          style: MarketplaceTypography.screenTitle,
        ),
        backgroundColor: MarketplaceColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshCategory,
        color: MarketplaceColors.primary,
        child: Obx(() {
          final state = controller.stateFor(kCategoryProducts);
          return state.value.when(
            onInitial: () => const SizedBox.shrink(),
            onLoading: () => GridView.builder(
              padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: MarketplaceSpacing.md,
                mainAxisSpacing: MarketplaceSpacing.md,
                childAspectRatio: 0.85,
              ),
              itemCount: 9,
              itemBuilder: (_, __) => const CategoryChipShimmer(),
            ),
            onSuccess: (data, _) {
              final categories = data as List<CategoryEntity>;
              return GridView.builder(
                padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: MarketplaceSpacing.md,
                  mainAxisSpacing: MarketplaceSpacing.md,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final cat = categories[index];
                  return _CategoryGridItem(
                    category: cat,
                    onTap: () => Get.toNamed(
                      Routes.MARKETPLACE_PRODUCTS_LIST,
                      arguments: {
                        'categoryId': cat.id,
                        'categoryName': cat.name,
                      },
                    ),
                  );
                },
              );
            },
            onError: (message, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message ?? LocaleKeys.error.tr),
                  TextButton(
                    onPressed: controller.refreshCategory,
                    child: Text(LocaleKeys.retry.tr),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({required this.category, required this.onTap});

  final CategoryEntity category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MarketplaceRadius.card),
              child: AppNetworkImage(
                imageUrl: category.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: MarketplaceTypography.cardSubtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

Also update `CategoryController` to load categories (not products — it is now the categories tab):

### **REWRITE** `lib/presentation/controllers/marketplace/category_controller.dart`

```dart
import 'package:get/get.dart';
import '../../../core/bases/base_state_controller.dart';
import '../../../domain/usecases/marketplace/product/get_categories_use_case.dart';
import '../../../domain/entities/marketplace/category_entity.dart';

const String kCategoryProducts = 'categories'; // note: reused key name kept for compat

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
```

Also update `category_binding.dart`:

### **REWRITE** `lib/presentation/pages/marketplace/category/bindings/category_binding.dart`

```dart
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
```

---

## 10. Update `app_pages.dart` — Add New Route

### **MODIFY** `lib/app/routes/app_pages.dart`

Add these `GetPage` entries to the routes list:

```dart
// Products list — handles "See All" + category-filtered views
GetPage(
  name: Routes.MARKETPLACE_PRODUCTS_LIST,
  page: () => const ProductsListPage(),
  binding: ProductsListBinding(),
  transition: Transition.rightToLeft,
),
```

Add the required imports at the top of `app_pages.dart`:

```dart
import '../presentation/pages/marketplace/category/products_list_page.dart';
import '../presentation/pages/marketplace/category/bindings/products_list_binding.dart';
```

---

## 11. New Locale Keys to Add

Already covered completely in §1 above.

---

## 12. Files Modified Summary

| File | Action | Notes |
|------|--------|-------|
| `core/localization/locale_keys.dart` | Modify | Add ~15 new keys |
| `core/localization/en.dart` | Modify | Add English strings |
| `core/localization/ar.dart` | Modify | Add Arabic strings |
| `app/routes/app_routes.dart` | Modify | Add `MARKETPLACE_PRODUCTS_LIST` |
| `app/routes/app_pages.dart` | Modify | Register `ProductsListPage` |
| `presentation/controllers/marketplace/products_list_controller.dart` | **CREATE** | Full filter + search + category logic |
| `presentation/controllers/marketplace/product_details_controller.dart` | **Rewrite** | Add quantity, addToCart, expand desc |
| `presentation/controllers/marketplace/category_controller.dart` | **Rewrite** | Now loads categories, not products |
| `presentation/pages/marketplace/category/products_list_page.dart` | **CREATE** | Full products grid + filter + search |
| `presentation/pages/marketplace/category/bindings/products_list_binding.dart` | **CREATE** | Binds ProductsListController |
| `presentation/pages/marketplace/category/category_page.dart` | **Rewrite** | Now shows category grid |
| `presentation/pages/marketplace/category/bindings/category_binding.dart` | **Rewrite** | Now uses GetCategoriesUseCase |
| `presentation/pages/marketplace/product/product_details_page.dart` | **Rewrite** | Full Figma-spec implementation |
| `core/components/marketplace/product_filter_bottom_sheet.dart` | **CREATE** | Sort + price range + rating filter |
| `presentation/pages/marketplace/home/home_page.dart` | Modify | Wire category tap + See All tap |

---

## Navigation Flow Summary

```
Home
 ├── Category chip tap → ProductsListPage(categoryId: X, categoryName: "Fruits")
 ├── "See All" (Popular Products) → ProductsListPage(no args = all products)
 └── Product card tap → ProductDetailsPage(productId: X)

Bottom Nav Tab 1 (Category)
 └── CategoryPage (3-col grid of all categories)
      └── Category tap → ProductsListPage(categoryId: X, categoryName: "...")

ProductsListPage
 ├── Search bar → filter products live (debounced)
 ├── Filter button → ProductFilterBottomSheet
 │    ├── Sort by (4 options)
 │    ├── Price range (RangeSlider)
 │    └── Min rating (1★–4★)
 └── Product card tap → ProductDetailsPage(productId: X)

ProductDetailsPage
 ├── Image gallery (swipeable PageView)
 ├── Rating row tap → ReviewsPage(productId: X)
 ├── "All Sellers" tap → ProductSellersPage(productId: X)
 └── "Add to Cart" → CartController.addToCart + snackbar confirmation
```

---

*Figma nodes: Product Details `112:687` · Category/Products `110:186` · File key `NO3iZ9gUb03kQWQELYob7F`*
*All translation keys use `LocaleKeys.xxx.tr` — never raw strings.*
