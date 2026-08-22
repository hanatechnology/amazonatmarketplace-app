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
import '../../../../core/components/marketplace/product_filter_bottom_sheet.dart';
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
                );
              }),
            ),

            // ── Results count ─────────────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                final state = controller.stateFor<List<ProductEntity>>(ProductsListController.kProducts);
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
      final state = controller.stateFor<List<ProductEntity>>(ProductsListController.kProducts);
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
          final products = data;

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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFilterBottomSheet(
        initial: controller.currentFilter.value,
        onApply: controller.applyFilter,
      ),
    );
  }
}

// ── Active Filter Chips ──────────────────────────────────

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({
    required this.filter,
    required this.onRemoveSort,
    required this.onRemovePrice,
  });

  final ProductFilter filter;
  final VoidCallback onRemoveSort;
  final VoidCallback onRemovePrice;

  String _sortLabel(ProductSortOption sort) {
    switch (sort) {
      case ProductSortOption.priceLowHigh:
        return LocaleKeys.sortPriceLowHigh.tr;
      case ProductSortOption.priceHighLow:
        return LocaleKeys.sortPriceHighLow.tr;
      case ProductSortOption.nameAsc:
        return LocaleKeys.sortNameAsc.tr;
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
