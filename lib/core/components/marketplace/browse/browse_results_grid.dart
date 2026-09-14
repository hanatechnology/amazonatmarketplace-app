import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../loading_shimmer.dart';
import '../product_card.dart';

/// The two-column product grid shared by search results and a category list.
class BrowseResultsGrid extends StatelessWidget {
  const BrowseResultsGrid({
    super.key,
    required this.products,
    required this.onTapProduct,
    required this.onAddToCart,
    this.gutter = 20,
  });

  final List<ProductEntity> products;
  final ValueChanged<ProductEntity> onTapProduct;
  final ValueChanged<ProductEntity> onAddToCart;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      sliver: SliverGrid.count(
        crossAxisCount: MarketplaceSpacing.productGridColumns,
        crossAxisSpacing: MarketplaceSpacing.productGridGap,
        mainAxisSpacing: MarketplaceSpacing.productGridGap,
        childAspectRatio: MarketplaceSpacing.productCardWidth /
            MarketplaceSpacing.productCardHeight,
        children: products
            .map(
              (product) => ProductCard(
                imageUrl: product.imageUrl,
                name: product.name,
                sellerName: product.sellerName,
                price: product.price,
                originalPrice: product.originalPrice,
                discountPercent: product.discountPercent,
                onTap: () => onTapProduct(product),
                onAddToCart: () => onAddToCart(product),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Skeletons in the real card geometry — the grid must not reflow when the
/// products land.
class BrowseGridShimmer extends StatelessWidget {
  const BrowseGridShimmer({super.key, this.gutter = 20, this.count = 4});

  final double gutter;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      sliver: SliverGrid.count(
        crossAxisCount: MarketplaceSpacing.productGridColumns,
        crossAxisSpacing: MarketplaceSpacing.productGridGap,
        mainAxisSpacing: MarketplaceSpacing.productGridGap,
        childAspectRatio: MarketplaceSpacing.productCardWidth /
            MarketplaceSpacing.productCardHeight,
        children: List.generate(count, (_) => const ProductCardShimmer()),
      ),
    );
  }
}

/// Inline "loading more" row for infinite scroll. Never a page bar — the web's
/// numbered pagination is deliberately not carried over.
class BrowseLoadingMore extends StatelessWidget {
  const BrowseLoadingMore({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: palette.brand,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            LocaleKeys.loadingMore.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 10.5,
              color: palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nothing matched. The query and the chips stay on screen above this — what
/// is shown here is the way out of it.
class BrowseNoResults extends StatelessWidget {
  const BrowseNoResults({
    super.key,
    required this.onClearFilters,
    required this.onBrowseCategories,
    this.canClearFilters = true,
  });

  final VoidCallback onClearFilters;
  final VoidCallback onBrowseCategories;
  final bool canClearFilters;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 36,
              color: palette.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            LocaleKeys.noProducts.tr,
            textAlign: TextAlign.center,
            style: MarketplaceTypography.heroDisplay.copyWith(
              fontSize: 24,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.noProductsMessage.tr,
            textAlign: TextAlign.center,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11.5,
              height: 1.7,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (canClearFilters)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onClearFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.brand,
                  foregroundColor: palette.onBrand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(MarketplaceRadius.full),
                  ),
                ),
                child: Text(
                  LocaleKeys.clearFilters.tr,
                  style: MarketplaceTypography.buttonLabel.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: palette.onBrand,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onBrowseCategories,
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textSecondary,
                side: BorderSide(color: palette.hairline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
              ),
              child: Text(
                LocaleKeys.browseCategories.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
