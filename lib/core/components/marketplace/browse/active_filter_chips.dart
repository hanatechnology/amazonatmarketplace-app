import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/product_filter.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/price_formatter.dart';

/// One removable chip per active filter, with a Clear all at the end of the
/// label row.
///
/// Matches the web's `ActiveFilterChip` behaviour; the Clear all is mobile-only.
/// Nothing renders when no filter is set.
class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    super.key,
    required this.filter,
    required this.onClearAll,
    required this.onRemoveSort,
    required this.onRemovePrice,
    required this.onRemoveCategory,
    this.onRemoveFeatured,
  });

  final ProductFilter filter;
  final VoidCallback onClearAll;
  final VoidCallback onRemoveSort;
  final VoidCallback onRemovePrice;
  final VoidCallback onRemoveCategory;
  final VoidCallback? onRemoveFeatured;

  @override
  Widget build(BuildContext context) {
    if (!filter.hasActiveFilters) return const SizedBox.shrink();

    final palette = context.palette;

    final chips = <Widget>[
      if (filter.sort != ProductSortOption.relevance)
        _Chip(label: _sortLabel(filter.sort), onRemove: onRemoveSort),
      if (filter.hasPriceRange)
        _Chip(label: _priceLabel(filter), onRemove: onRemovePrice),
      if (filter.categoryId != null)
        _Chip(
          label: filter.categoryName ?? LocaleKeys.category.tr,
          onRemove: onRemoveCategory,
        ),
      if (filter.featuredSection != null && onRemoveFeatured != null)
        _Chip(
          label: _featuredLabel(filter.featuredSection!),
          onRemove: onRemoveFeatured!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                LocaleKeys.activeFilters.tr.toUpperCase(),
                style: MarketplaceTypography.labelCaps.copyWith(
                  fontSize: 9.5,
                  color: palette.textMuted,
                  letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.1,
                ),
              ),
            ),
            GestureDetector(
              onTap: onClearAll,
              behavior: HitTestBehavior.opaque,
              child: Text(
                LocaleKeys.clearAll.tr,
                style: MarketplaceTypography.pillLabel.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: palette.brand,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  static String _sortLabel(ProductSortOption sort) => switch (sort) {
        ProductSortOption.relevance => LocaleKeys.sortRelevance.tr,
        ProductSortOption.priceLowHigh => LocaleKeys.sortPriceLowHigh.tr,
        ProductSortOption.priceHighLow => LocaleKeys.sortPriceHighLow.tr,
        ProductSortOption.nameAsc => LocaleKeys.sortNameAsc.tr,
      };

  /// `200 – 800 LYD`, Latin digits, currency trailing, in both languages.
  static String _priceLabel(ProductFilter filter) {
    final low = PriceFormatter.amount(filter.minPrice ?? 0);
    final high = filter.maxPrice;
    final range = high == null ? low : '$low – ${PriceFormatter.amount(high)}';
    return '\u{2066}$range ${PriceFormatter.unit()}\u{2069}';
  }

  static String _featuredLabel(String section) => switch (section) {
        'NEW_ARRIVALS' => LocaleKeys.newArrivals.tr,
        'BEST_SELLERS' => LocaleKeys.bestSellers.tr,
        'ADMIN_PICKS' => LocaleKeys.adminPicks.tr,
        _ => section,
      };
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 32,
      padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
        border: Border.all(color: palette.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: MarketplaceTypography.pillLabel.copyWith(
                color: palette.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.close_rounded,
              size: 13,
              color: palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
