import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/browse/active_filter_chips.dart';
import '../../../../core/components/marketplace/browse/browse_results_grid.dart';
import '../../../../core/components/marketplace/product_filter_bottom_sheet.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/category_entity.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../domain/entities/marketplace/product_filter.dart';
import '../../../controllers/marketplace/cart_controller.dart';
import '../../../controllers/marketplace/product_search_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';
import '../../../../core/components/marketplace/cart/cart_floating_button.dart';

/// Search — one screen with two faces.
///
/// Nothing asked for yet: recent searches (device-local, no endpoint), the
/// three `featured_section` shortcuts, and the category list. As soon as there
/// is a term or a filter it becomes results, paginated by infinite scroll
/// rather than the web's numbered page bar.
class ProductSearchPage extends GetView<ProductSearchController> {
  const ProductSearchPage({super.key});

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
        child: Obx(
          () => controller.isBrowsing
              ? const _EntryLayout()
              : const _ResultsLayout(),
        ),
      )),
    );
  }
}

// ── Shared chrome ───────────────────────────────────────────────────────────

class _NavRow extends GetView<ProductSearchController> {
  const _NavRow({this.showFilterButton = false});

  final bool showFilterButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          const BackButtonSlot(),
          const SizedBox(width: 10),
          const Expanded(child: _SearchField()),
          if (showFilterButton) ...[
            const SizedBox(width: 10),
            const _FilterButton(),
          ],
        ],
      ),
    );
  }
}

/// Debounced so a keystroke does not become a request.
class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = Get.find<ProductSearchController>();
  late final TextEditingController _text =
      TextEditingController(text: _controller.searchQuery.value);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _controller.onSearchChanged(value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: palette.brand, width: 1.4),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 16, color: palette.brand),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _text,
              onChanged: _onChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                _controller.submitSearch(value.trim());
              },
              textInputAction: TextInputAction.search,
              cursorColor: palette.brand,
              style: MarketplaceTypography.pillLabel.copyWith(
                fontSize: 12.5,
                color: palette.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: LocaleKeys.searchHintShort.tr,
                hintStyle: MarketplaceTypography.pillLabel.copyWith(
                  fontSize: 12.5,
                  color: palette.textMuted,
                ),
              ),
            ),
          ),
          Obx(() {
            if (_controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                _text.clear();
                _debounce?.cancel();
                _controller.clearQuery();
              },
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.close_rounded,
                size: 15,
                color: palette.textMuted,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Sliders button, with a count badge when filters are on.
class _FilterButton extends GetView<ProductSearchController> {
  const _FilterButton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: () => Get.bottomSheet(
        ProductFilterBottomSheet(
          initial: controller.currentFilter.value,
          categories: controller.categories,
          onApply: controller.applyFilter,
        ),
        isScrollControlled: true,
        backgroundColor: const Color(0x00000000),
      ),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surface,
              shape: BoxShape.circle,
              border: Border.all(color: palette.hairline),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 17,
              color: palette.textPrimary,
            ),
          ),
          Obx(() {
            final count = _activeCount(controller.currentFilter.value);
            if (count == 0) return const SizedBox.shrink();
            return PositionedDirectional(
              top: -2,
              end: -2,
              child: Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  textDirection: TextDirection.ltr,
                  style: MarketplaceTypography.labelCaps.copyWith(
                    fontSize: 8.5,
                    color: palette.onAccent,
                    letterSpacing: 0,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static int _activeCount(ProductFilter filter) {
    var count = 0;
    if (filter.sort != ProductSortOption.relevance) count++;
    if (filter.hasPriceRange) count++;
    if (filter.categoryId != null) count++;
    if (filter.featuredSection != null) count++;
    return count;
  }
}

// ── Entry layout ────────────────────────────────────────────────────────────

class _EntryLayout extends GetView<ProductSearchController> {
  const _EntryLayout();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        ProductSearchPage.gutter,
        0,
        ProductSearchPage.gutter,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _NavRow(),
          const SizedBox(height: 6),
          Text(
            LocaleKeys.searchTheMarket.tr,
            style: MarketplaceTypography.heroDisplay.copyWith(
              fontSize: 29,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            LocaleKeys.searchSubtitle.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11,
              color: palette.textSecondary,
            ),
          ),
          Obx(() {
            if (controller.recentSearches.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHead(
                  title: LocaleKeys.recentSearches.tr,
                  actionLabel: LocaleKeys.clearAll.tr,
                  onAction: controller.clearRecentSearches,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.recentSearches
                      .map(
                        (term) => _RecentChip(
                          term: term,
                          onTap: () => controller.submitSearch(term),
                          onRemove: () => controller.removeRecentSearch(term),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          }),
          _SectionHead(title: LocaleKeys.shopBy.tr),
          Row(
            children: [
              for (var i = 0;
                  i < ProductSearchController.featuredSections.length;
                  i++) ...[
                if (i > 0) const SizedBox(width: 9),
                Expanded(
                  child: _FeaturedCard(
                    section: ProductSearchController.featuredSections[i],
                    onTap: () => controller.selectFeaturedSection(
                      ProductSearchController.featuredSections[i],
                    ),
                  ),
                ),
              ],
            ],
          ),
          _SectionHead(title: LocaleKeys.browseCategories.tr),
          Obx(() {
            final categories = controller.categories;
            if (categories.isEmpty) return const SizedBox.shrink();
            return Column(
              children: [
                for (var i = 0; i < categories.length; i++)
                  _CategoryRow(
                    category: categories[i],
                    isLast: i == categories.length - 1,
                    onTap: () => controller.selectCategory(categories[i]),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(
                actionLabel!.toUpperCase(),
                style: MarketplaceTypography.labelCaps.copyWith(
                  fontSize: 10,
                  color: palette.textMuted,
                  letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.term,
    required this.onTap,
    required this.onRemove,
  });

  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 32,
        padding: const EdgeInsetsDirectional.only(start: 12, end: 10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          border: Border.all(color: palette.hairline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 12,
              color: palette.textMuted,
            ),
            const SizedBox(width: 7),
            Text(
              term,
              style: MarketplaceTypography.pillLabel.copyWith(
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(width: 7),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.close_rounded,
                size: 12,
                color: palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One `featured_section` shortcut. The API returns no artwork for a section,
/// so the card is typographic rather than a photo tile.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.section, required this.onTap});

  final String section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 78,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: palette.surfaceSunken,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(_icon, size: 17, color: palette.brand),
            Text(
              _label,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (section) {
        'NEW_ARRIVALS' => Icons.auto_awesome_outlined,
        'BEST_SELLERS' => Icons.local_fire_department_outlined,
        _ => Icons.workspace_premium_outlined,
      };

  String get _label => switch (section) {
        'NEW_ARRIVALS' => LocaleKeys.newArrivals.tr,
        'BEST_SELLERS' => LocaleKeys.bestSellers.tr,
        _ => LocaleKeys.adminPicks.tr,
      };
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.isLast,
    required this.onTap,
  });

  final CategoryEntity category;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: palette.hairline)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(13),
              ),
              clipBehavior: Clip.hardEdge,
              child: AppNetworkImage(
                imageUrl: category.imageUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.hasChildren
                        ? LocaleKeys.subcategoriesCount.trParams(
                            {'count': '${category.subcategoryCount}'},
                          )
                        : LocaleKeys.noSubcategories.tr,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results layout ──────────────────────────────────────────────────────────

class _ResultsLayout extends GetView<ProductSearchController> {
  const _ResultsLayout();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final state =
          controller.stateFor<List<ProductEntity>>(kSearchResults).value;
      final query = controller.searchQuery.value;

      return RefreshIndicator(
        onRefresh: controller.refreshResults,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: ProductSearchPage.gutter,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _NavRow(showFilterButton: true),
                      const SizedBox(height: 6),
                      if (query.isNotEmpty) ...[
                        Text(
                          LocaleKeys.searchResultsFor.tr.toUpperCase(),
                          style: MarketplaceTypography.labelCaps.copyWith(
                            fontSize: 9.5,
                            color: palette.textMuted,
                            letterSpacing:
                                MarketplaceTypography.isArabic ? 0 : 1.2,
                          ),
                        ),
                        Text(
                          '«$query»',
                          style: MarketplaceTypography.heroDisplay.copyWith(
                            fontSize: 24,
                            color: palette.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                      const SizedBox(height: 14),
                      ActiveFilterChips(
                        filter: controller.currentFilter.value,
                        onClearAll: controller.clearFilters,
                        onRemoveSort: controller.removeSort,
                        onRemovePrice: controller.removePriceRange,
                        onRemoveCategory: controller.removeCategory,
                        onRemoveFeatured: controller.removeFeaturedSection,
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              ...state.when(
                onInitial: () => [
                  const BrowseGridShimmer(gutter: ProductSearchPage.gutter),
                ],
                onLoading: () => [
                  const BrowseGridShimmer(gutter: ProductSearchPage.gutter),
                ],
                onSuccess: (products, _) => products.isEmpty
                    ? [
                        SliverToBoxAdapter(
                          child: BrowseNoResults(
                            canClearFilters:
                                controller.currentFilter.value.hasActiveFilters,
                            onClearFilters: controller.clearFilters,
                            onBrowseCategories: () => Get.offAllNamed(
                              Routes.MARKETPLACE_MAIN,
                              arguments: const {'tab': 1},
                            ),
                          ),
                        ),
                      ]
                    : [
                        BrowseResultsGrid(
                          products: products,
                          gutter: ProductSearchPage.gutter,
                          onTapProduct: controller.openProduct,
                          onAddToCart: (product) => Get.find<CartController>()
                              .addProduct(product, 1),
                        ),
                      ],
                onError: (message, _) => [
                  SliverToBoxAdapter(
                    child: _ResultsError(message: message),
                  ),
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
    });
  }
}

class _ResultsError extends GetView<ProductSearchController> {
  const _ResultsError({required this.message});

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
            onPressed: controller.search,
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
