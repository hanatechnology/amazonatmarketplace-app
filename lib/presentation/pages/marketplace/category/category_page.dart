import 'package:flutter/material.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/category_entity.dart';
import '../../../controllers/marketplace/category_controller.dart';

/// The Categories tab: every craft on the marketplace, as photo tiles.
///
/// Reads `GET /categories/tree`, because the subcategory count under each name
/// comes from `children` and the flat list does not carry it.
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshCategory,
          color: palette.brand,
          backgroundColor: palette.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 14),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.categoriesTitle.tr,
                        style: MarketplaceTypography.heroDisplay.copyWith(
                          fontSize: 29,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        LocaleKeys.categoriesSubtitle.tr,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 11,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                final state = controller
                    .stateFor<List<CategoryEntity>>(kCategoryProducts)
                    .value;

                return state.when(
                  onInitial: () => const _TilesShimmer(),
                  onLoading: () => const _TilesShimmer(),
                  onSuccess: (_, __) {
                    final categories = controller.topLevel;
                    if (categories.isEmpty) {
                      return const SliverToBoxAdapter(child: _NoCategories());
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _gutter,
                      ),
                      sliver: SliverGrid.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: MarketplaceSpacing.productCardWidth /
            MarketplaceSpacing.productCardHeight,
                        children: categories
                            .map(
                              (category) => _CategoryTile(
                                category: category,
                                onTap: () =>
                                    controller.openCategory(category),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                  onError: (message, _) => SliverToBoxAdapter(
                    child: _CategoriesError(
                      message: message,
                      onRetry: controller.loadCategories,
                    ),
                  ),
                );
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final CategoryEntity category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surfaceSunken,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.hairline),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              imageUrl: category.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Scrim weighted to the bottom so the name stays readable on any
            // photograph, in either theme.
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x14080B09), Color(0xD6080B09)],
                    stops: [0.35, 1.0],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 12,
              end: 12,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.name,
                          style: MarketplaceTypography.rowTitle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF5F7EE),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (category.hasChildren) ...[
                          const SizedBox(height: 2),
                          Text(
                            LocaleKeys.subcategoriesCount.trParams(
                              {'count': '${category.subcategoryCount}'},
                            ),
                            style: MarketplaceTypography.rowMeta.copyWith(
                              color: const Color(0xB3F5F7EE),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0x33F5F7EE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: const Color(0xFFF5F7EE),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TilesShimmer extends StatelessWidget {
  const _TilesShimmer();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: CategoryPage._gutter,
      ),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: MarketplaceSpacing.productCardWidth /
            MarketplaceSpacing.productCardHeight,
        children: List.generate(
          6,
          (_) => Shimmer.fromColors(
            baseColor: palette.shimmerBase,
            highlightColor: palette.shimmerHighlight,
            child: Container(
              decoration: BoxDecoration(
                color: palette.shimmerBase,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoCategories extends StatelessWidget {
  const _NoCategories();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              size: 30,
              color: palette.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            LocaleKeys.noProductsMessage.tr,
            textAlign: TextAlign.center,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 12,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesError extends StatelessWidget {
  const _CategoriesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
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
            onPressed: onRetry,
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
