import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/browse/active_filter_chips.dart';
import '../../../../core/components/marketplace/browse/browse_results_grid.dart';
import '../../../../core/components/marketplace/product_filter_bottom_sheet.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../controllers/marketplace/cart_controller.dart';
import '../../../controllers/marketplace/products_list_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';
import '../../../../core/components/marketplace/cart/cart_floating_button.dart';

/// Products inside one category, or everything when opened from "See all".
///
/// The subcategory rail re-queries `category_id` with the child's id — the
/// parameter takes exactly one value, so a subcategory replaces its parent
/// rather than narrowing it.
class ProductsListPage extends GetView<ProductsListController> {
  const ProductsListPage({super.key});

  static const double gutter = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      floatingActionButton: const CartFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StickyBackBar(
        child:  SafeArea(
        bottom: false,
        child: Obx(() {
          final state = controller
              .stateFor<List<ProductEntity>>(ProductsListController.kProducts)
              .value;

          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: palette.brand,
            backgroundColor: palette.surface,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                final metrics = scroll.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                  controller.loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: gutter),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _NavRow(),
                          const SizedBox(height: 6),
                          if (controller.isCategoryView)
                            Text(
                              LocaleKeys.category.tr.toUpperCase(),
                              style: MarketplaceTypography.labelCaps.copyWith(
                                fontSize: 9.5,
                                color: palette.textMuted,
                                letterSpacing:
                                    MarketplaceTypography.isArabic ? 0 : 1.2,
                              ),
                            ),
                          Text(
                            controller.isCategoryView
                                ? controller.pageTitle
                                : LocaleKeys.allProductsTitle.tr,
                            style: MarketplaceTypography.heroDisplay.copyWith(
                              fontSize: 26,
                              color: palette.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            LocaleKeys.productsFound.trParams(
                              {'count': '${controller.totalResults.value}'},
                            ),
                            style: MarketplaceTypography.rowMeta.copyWith(
                              fontSize: 11,
                              color: palette.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _SubcategoryRail()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(gutter, 0, gutter, 14),
                    sliver: SliverToBoxAdapter(
                      child: ActiveFilterChips(
                        filter: controller.currentFilter.value,
                        onClearAll: controller.clearFilters,
                        onRemoveSort: controller.removeSort,
                        onRemovePrice: controller.removePriceRange,
                        // The category is the screen itself here, so it is not
                        // offered as a removable chip.
                        onRemoveCategory: controller.clearFilters,
                      ),
                    ),
                  ),
                  ...state.when(
                    onInitial: () => [const BrowseGridShimmer(gutter: gutter)],
                    onLoading: () => [const BrowseGridShimmer(gutter: gutter)],
                    onSuccess: (products, _) => products.isEmpty
                        ? [
                            SliverToBoxAdapter(
                              child: BrowseNoResults(
                                canClearFilters: controller
                                    .currentFilter.value.hasActiveFilters,
                                onClearFilters: controller.clearFilters,
                                onBrowseCategories: Get.back,
                              ),
                            ),
                          ]
                        : [
                            BrowseResultsGrid(
                              products: products,
                              gutter: gutter,
                              onTapProduct: controller.openProduct,
                              onAddToCart: (product) =>
                                  Get.find<CartController>()
                                      .addProduct(product, 1),
                            ),
                          ],
                    onError: (message, _) => [
                      SliverToBoxAdapter(child: _ListError(message: message)),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: controller.isLoadingMore.value
                        ? const BrowseLoadingMore()
                        : const SizedBox(height: 20),
                  ),
                ],
              ),
            ),
          );
        }),
      )),
    );
  }
}

class _NavRow extends GetView<ProductsListController> {
  const _NavRow();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: 46,
      child: Row(
        children: [
          const BackButtonSlot(),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.bottomSheet(
              ProductFilterBottomSheet(
                initial: controller.currentFilter.value,
                onApply: controller.applyFilter,
              ),
              isScrollControlled: true,
              backgroundColor: const Color(0x00000000),
            ),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                border: Border.all(color: palette.hairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: palette.textPrimary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    LocaleKeys.filterTitle.tr,
                    style: MarketplaceTypography.pillLabel.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-select rail of this category's children. Absent for a leaf category
/// and for the "see all" view — there is nothing under either.
class _SubcategoryRail extends GetView<ProductsListController> {
  const _SubcategoryRail();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subcategories = controller.subcategories;
      if (subcategories.isEmpty) return const SizedBox.shrink();

      final selected = controller.selectedSubcategoryId.value;

      return SizedBox(
        height: 33,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(
            start: ProductsListPage.gutter,
            end: ProductsListPage.gutter,
          ),
          itemCount: subcategories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            if (index == 0) {
              return _RailChip(
                label: LocaleKeys.categoryFilterAll.tr,
                isSelected: selected == null,
                onTap: () => controller.selectSubcategory(null),
              );
            }
            final subcategory = subcategories[index - 1];
            return _RailChip(
              label: subcategory.name,
              isSelected: selected == subcategory.id,
              onTap: () => controller.selectSubcategory(subcategory.id),
            );
          },
        ),
      );
    });
  }
}

class _RailChip extends StatelessWidget {
  const _RailChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? palette.brand : palette.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          border: Border.all(
            color: isSelected ? palette.brand : palette.hairline,
          ),
        ),
        child: Text(
          label,
          style: MarketplaceTypography.pillLabel.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? palette.onBrand : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ListError extends GetView<ProductsListController> {
  const _ListError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 12,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: controller.loadProducts,
            child: Text(
              LocaleKeys.retry.tr,
              style: MarketplaceTypography.buttonLabel.copyWith(
                fontSize: 12.5,
                color: palette.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
