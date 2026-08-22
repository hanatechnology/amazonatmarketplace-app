import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/feedback/error_widget.dart';
import '../../../../core/components/feedback/loading_indicator.dart';
import '../../../../core/components/marketplace/product_card.dart';
import '../../../../core/components/marketplace/product_filter_bottom_sheet.dart';
import '../../../../core/components/marketplace/search_bar_widget.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../domain/entities/marketplace/product_filter.dart';
import '../../../controllers/marketplace/cart_controller.dart';
import '../../../controllers/marketplace/product_search_controller.dart';

/// Search results screen.
///
/// Opened from the home search bar. Results fade and rise in as they arrive,
/// staggered by index, so a new result set reads as arriving rather than
/// snapping into place.
class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final controller = Get.find<ProductSearchController>();
  final _scrollController = ScrollController();
  late final TextEditingController _searchController =
      TextEditingController(text: controller.searchQuery.value);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >=
        position.maxScrollExtent - position.viewportDimension) {
      controller.loadMore();
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFilterBottomSheet(
        initial: controller.currentFilter.value,
        categories: controller.categories,
        onApply: controller.applyFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: AppBar(
        backgroundColor: MarketplaceColors.surface,
        elevation: 0,
        title: Text(
          LocaleKeys.searchProducts.tr,
          style: MarketplaceTypography.sectionHeading,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MarketplaceSpacing.screenPaddingH,
                MarketplaceSpacing.md,
                MarketplaceSpacing.screenPaddingH,
                MarketplaceSpacing.sm,
              ),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: LocaleKeys.searchHint.tr,
                onSearch: controller.onSearchChanged,
                onFilter: _openFilterSheet,
              ),
            ),
            _buildActiveFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshResults,
                color: MarketplaceColors.primary,
                child: Obx(() {
                  final state = controller
                      .stateFor<List<ProductEntity>>(kSearchResults)
                      .value;
                  return state.when(
                    onInitial: () => const SizedBox.shrink(),
                    onLoading: () => const Center(child: LoadingIndicator()),
                    onSuccess: (products, _) => products.isEmpty
                        ? _buildEmpty()
                        : _buildGrid(products),
                    onError: (message, _) => BaseErrorWidget(
                      message: message,
                      onRetry: controller.search,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chips for each active filter, removable individually — mirrors the web,
  /// which has per-chip removal rather than one clear-all button.
  Widget _buildActiveFilters() {
    return Obx(() {
      final filter = controller.currentFilter.value;
      if (!filter.hasActiveFilters) return const SizedBox.shrink();

      final chips = <Widget>[
        if (filter.sort != ProductSortOption.relevance)
          _RemovableChip(
            label: _sortLabel(filter.sort),
            onRemove: controller.removeSort,
          ),
        if (filter.hasPriceRange)
          _RemovableChip(
            label: '${(filter.minPrice ?? 0).toInt()} – '
                '${(filter.maxPrice ?? 0).toInt()}',
            onRemove: controller.removePriceRange,
          ),
        if (filter.categoryId != null)
          _RemovableChip(
            label: filter.categoryName ?? LocaleKeys.category.tr,
            onRemove: controller.removeCategory,
          ),
      ];

      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(
            start: MarketplaceSpacing.screenPaddingH,
            end: MarketplaceSpacing.screenPaddingH,
            bottom: MarketplaceSpacing.sm,
          ),
          child: Row(
            children: [
              for (final chip in chips) ...[
                chip,
                const SizedBox(width: MarketplaceSpacing.sm),
              ],
              TextButton(
                onPressed: controller.clearFilters,
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
      );
    });
  }

  String _sortLabel(ProductSortOption sort) => switch (sort) {
        ProductSortOption.relevance => LocaleKeys.sortRelevance.tr,
        ProductSortOption.priceLowHigh => LocaleKeys.sortPriceLowHigh.tr,
        ProductSortOption.priceHighLow => LocaleKeys.sortPriceHighLow.tr,
        ProductSortOption.nameAsc => LocaleKeys.sortNameAsc.tr,
      };

  Widget _buildGrid(List<ProductEntity> products) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MarketplaceSpacing.productGridColumns,
        crossAxisSpacing: MarketplaceSpacing.productGridGap,
        mainAxisSpacing: MarketplaceSpacing.productGridGap,
        childAspectRatio: MarketplaceSpacing.productCardWidth /
            MarketplaceSpacing.productCardHeight,
      ),
      itemCount: products.length + 1,
      itemBuilder: (context, index) {
        // Trailing slot carries the load-more spinner.
        if (index == products.length) {
          return Obx(() => controller.isLoadingMore.value
              ? const Center(child: LoadingIndicator())
              : const SizedBox.shrink());
        }

        final product = products[index];
        return _StaggeredReveal(
          // Only the first screenful staggers; beyond that the delay would be
          // long enough to look like lag.
          delay: Duration(milliseconds: 40 * (index % 8)),
          child: ProductCard(
            imageUrl: product.imageUrl,
            name: product.name,
            sellerName: product.sellerName,
            price: product.price,
            rating: product.rating,
            onTap: () => controller.openProduct(product),
            onAddToCart: () async {
              await Get.find<CartController>().addProduct(product, 1);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        const Icon(
          Icons.search_off_rounded,
          size: 64,
          color: MarketplaceColors.iconInactive,
        ),
        const SizedBox(height: MarketplaceSpacing.md),
        Text(
          LocaleKeys.noProducts.tr,
          textAlign: TextAlign.center,
          style: MarketplaceTypography.sectionHeading,
        ),
        const SizedBox(height: MarketplaceSpacing.sm),
        Text(
          LocaleKeys.noProductsMessage.tr,
          textAlign: TextAlign.center,
          style: MarketplaceTypography.body.copyWith(
            color: MarketplaceColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Fades and lifts its child in once, after [delay].
class _StaggeredReveal extends StatefulWidget {
  const _StaggeredReveal({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  State<_StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<_StaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _animation.forward();
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curve),
        child: widget.child,
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 12, end: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: MarketplaceColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(MarketplaceRadius.smallButton),
        border: Border.all(color: MarketplaceColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: MarketplaceTypography.cardTitle.copyWith(
              color: MarketplaceColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: MarketplaceColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
