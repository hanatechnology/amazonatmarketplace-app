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
                                  '$stars+',
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
