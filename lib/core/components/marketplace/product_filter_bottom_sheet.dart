import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/entities/marketplace/product_filter.dart';
import '../../localization/locale_keys.dart';
import '../../theme/marketplace_palette.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_typography.dart';
import '../../utils/price_formatter.dart';

/// Filter sheet for any product list.
///
/// Takes a filter and hands one back — it holds no controller reference, so
/// search and the category list can both share it.
///
/// Four sort options, not five: `sort_rating` exists as a string but the API
/// returns no rating field, so a "highest rated" sort could not do anything.
/// There is likewise no in-stock, discount or multi-category filter here —
/// `GET /products` has no parameter for any of them.
class ProductFilterBottomSheet extends StatefulWidget {
  const ProductFilterBottomSheet({
    super.key,
    required this.initial,
    required this.onApply,
    this.categories = const [],
    this.maxPrice = 2000,
  });

  final ProductFilter initial;
  final ValueChanged<ProductFilter> onApply;
  final List<CategoryEntity> categories;

  /// Upper bound of the range control. Not a filter in itself — the query only
  /// carries the handles the customer actually moved.
  final double maxPrice;

  @override
  State<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late ProductFilter _temp = widget.initial;

  void _update(ProductFilter next) => setState(() => _temp = next);

  static const _sortOptions = <(ProductSortOption, String)>[
    (ProductSortOption.relevance, LocaleKeys.sortRelevance),
    (ProductSortOption.priceLowHigh, LocaleKeys.sortPriceLowHigh),
    (ProductSortOption.priceHighLow, LocaleKeys.sortPriceHighLow),
    (ProductSortOption.nameAsc, LocaleKeys.sortNameAsc),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final low = _temp.minPrice ?? 0;
    final high = _temp.maxPrice ?? widget.maxPrice;

    // Presented with isScrollControlled, so the sheet is free to grow to the
    // full screen and slide its grab handle under the status bar. Cap it at the
    // safe area instead, leaving the notch clear on every device.
    final topInset = MediaQuery.paddingOf(context).top;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height -
            topInset -
            MarketplaceSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: palette.hairline)),
        ),
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(MarketplaceRadius.full),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      LocaleKeys.filterTitle.tr,
                      style: MarketplaceTypography.heroDisplay.copyWith(
                        fontSize: 23,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _update(const ProductFilter()),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      LocaleKeys.clearAll.tr.toUpperCase(),
                      style: MarketplaceTypography.labelCaps.copyWith(
                        fontSize: 10,
                        color: palette.textMuted,
                        letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(text: LocaleKeys.sortBy.tr),
                    for (final option in _sortOptions)
                      _SortOptionTile(
                        label: option.$2.tr,
                        isSelected: _temp.sort == option.$1,
                        onTap: () => _update(_temp.copyWith(sort: option.$1)),
                      ),
                    _SectionLabel(text: LocaleKeys.priceRange.tr),
                    Row(
                      children: [
                        Expanded(
                          child: _PriceField(
                            label: LocaleKeys.priceFrom.tr,
                            value: low,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _PriceField(
                            label: LocaleKeys.priceTo.tr,
                            value: high,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: palette.brand,
                        inactiveTrackColor: palette.surfaceSunken,
                        thumbColor: palette.surface,
                        overlayColor: palette.brand.withValues(alpha: 0.12),
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 9,
                        ),
                      ),
                      child: RangeSlider(
                        values: RangeValues(
                          low.clamp(0, widget.maxPrice),
                          high.clamp(0, widget.maxPrice),
                        ),
                        min: 0,
                        max: widget.maxPrice,
                        divisions: 40,
                        onChanged: (range) => _update(
                          _temp.copyWith(
                            minPrice: range.start,
                            maxPrice: range.end,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _EndLabel(value: 0),
                          _EndLabel(value: widget.maxPrice),
                        ],
                      ),
                    ),
                    if (widget.categories.isNotEmpty) ...[
                      _SectionLabel(text: LocaleKeys.category.tr),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoiceChip(
                            label: LocaleKeys.categoryFilterAll.tr,
                            isSelected: _temp.categoryId == null,
                            onTap: () =>
                                _update(_temp.copyWith(clearCategory: true)),
                          ),
                          for (final category in widget.categories)
                            _ChoiceChip(
                              label: category.name,
                              isSelected: _temp.categoryId == category.id,
                              onTap: () => _update(
                                _temp.categoryId == category.id
                                    ? _temp.copyWith(clearCategory: true)
                                    : _temp.copyWith(
                                        categoryId: category.id,
                                        categoryName: category.name,
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.hairline)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_temp);
                        Get.back();
                      },
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
                        LocaleKeys.applyFilters.tr,
                        style: MarketplaceTypography.buttonLabel.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.onBrand,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: MarketplaceTypography.labelCaps.copyWith(
          color: palette.textMuted,
          letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.1,
        ),
      ),
    );
  }
}

/// Read-out of one end of the range. The slider is the control; these say what
/// it currently means, with the currency trailing the figure.
class _PriceField extends StatelessWidget {
  const _PriceField({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.hairline),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: palette.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            PriceFormatter.amount(value),
            textDirection: TextDirection.ltr,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            PriceFormatter.unit(),
            style: MarketplaceTypography.priceUnit.copyWith(
              fontSize: 9,
              color: palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndLabel extends StatelessWidget {
  const _EndLabel({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Text(
      PriceFormatter.formatWithUnit(value),
      textDirection: TextDirection.ltr,
      style: MarketplaceTypography.rowMeta.copyWith(
        fontSize: 9.5,
        color: palette.textMuted,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
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
        height: 33,
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
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? palette.surfaceSunken : const Color(0x00000000),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? palette.brand : const Color(0x00000000),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 17,
              height: 17,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? palette.brand : palette.hairline,
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: palette.brand,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: MarketplaceTypography.pillLabel.copyWith(
                  fontSize: 12,
                  color: palette.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 15, color: palette.brand),
          ],
        ),
      ),
    );
  }
}
