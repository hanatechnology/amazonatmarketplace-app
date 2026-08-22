import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../localization/locale_keys.dart';
import '../../../domain/entities/marketplace/category_entity.dart';
import '../../../domain/entities/marketplace/product_filter.dart';

/// Filter sheet for any product list.
///
/// Takes a filter and hands one back — it holds no controller reference, so
/// home, search and the category list can all share it.
class ProductFilterBottomSheet extends StatefulWidget {
  const ProductFilterBottomSheet({
    super.key,
    required this.initial,
    required this.onApply,
    this.categories = const [],
    this.maxPrice = 500,
  });

  final ProductFilter initial;
  final ValueChanged<ProductFilter> onApply;
  final List<CategoryEntity> categories;
  final double maxPrice;

  @override
  State<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late ProductFilter _temp = widget.initial;

  void _update(ProductFilter next) => setState(() => _temp = next);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: MarketplaceColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MarketplaceRadius.bottomNav),
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  onPressed: () => _update(const ProductFilter()),
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

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MarketplaceSpacing.screenPaddingH),
              child: Column(
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
                    (ProductSortOption.priceLowHigh,
                        LocaleKeys.sortPriceLowHigh.tr),
                    (ProductSortOption.priceHighLow,
                        LocaleKeys.sortPriceHighLow.tr),
                    (ProductSortOption.nameAsc, LocaleKeys.sortNameAsc.tr),
                  ].map((option) => _SortOptionTile(
                        label: option.$2,
                        isSelected: _temp.sort == option.$1,
                        onTap: () => _update(_temp.copyWith(sort: option.$1)),
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
                        '${(_temp.minPrice ?? 0).toInt()} – '
                        '${(_temp.maxPrice ?? widget.maxPrice).toInt()}',
                        style: MarketplaceTypography.cardTitle.copyWith(
                          color: MarketplaceColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MarketplaceSpacing.sm),
                  RangeSlider(
                    values: RangeValues(
                      _temp.minPrice ?? 0,
                      _temp.maxPrice ?? widget.maxPrice,
                    ),
                    min: 0,
                    max: widget.maxPrice,
                    divisions: 50,
                    activeColor: MarketplaceColors.primary,
                    inactiveColor: MarketplaceColors.stroke,
                    onChanged: (range) => _update(
                      _temp.copyWith(minPrice: range.start, maxPrice: range.end),
                    ),
                  ),

                  if (widget.categories.isNotEmpty) ...[
                    const SizedBox(height: MarketplaceSpacing.lg),
                    const Divider(color: MarketplaceColors.stroke),
                    const SizedBox(height: MarketplaceSpacing.lg),

                    // ── Category ────────────────────────
                    Text(
                      LocaleKeys.category.tr,
                      style: MarketplaceTypography.sectionSubheading,
                    ),
                    const SizedBox(height: MarketplaceSpacing.sm),
                    Wrap(
                      spacing: MarketplaceSpacing.sm,
                      runSpacing: MarketplaceSpacing.sm,
                      children: widget.categories.map((category) {
                        final isSelected = _temp.categoryId == category.id;
                        return _ChoiceChip(
                          label: category.name,
                          isSelected: isSelected,
                          onTap: () => _update(
                            isSelected
                                ? _temp.copyWith(clearCategory: true)
                                : _temp.copyWith(
                                    categoryId: category.id,
                                    categoryName: category.name,
                                  ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: MarketplaceSpacing.xl),
                ],
              ),
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
                widget.onApply(_temp);
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? MarketplaceColors.primary
              : MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.smallButton),
          border: Border.all(
            color: isSelected
                ? MarketplaceColors.primary
                : MarketplaceColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: MarketplaceTypography.cardTitle.copyWith(
            color: isSelected
                ? MarketplaceColors.onPrimary
                : MarketplaceColors.textBody,
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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
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
