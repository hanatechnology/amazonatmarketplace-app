import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/city_entity.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

/// Searchable city picker.
///
/// A sheet rather than a `DropdownButtonFormField`: `GET /dropdowns/cities`
/// returns every Libyan city the backend knows, which is far more than a
/// dropdown can show without scrolling blind.
class CityPickerSheet extends StatefulWidget {
  const CityPickerSheet({
    super.key,
    required this.cities,
    this.selectedId,
  });

  final List<CityEntity> cities;
  final String? selectedId;

  static Future<CityEntity?> show({
    required List<CityEntity> cities,
    String? selectedId,
  }) {
    return Get.bottomSheet<CityEntity>(
      CityPickerSheet(cities: cities, selectedId: selectedId),
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
    );
  }

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<CityEntity> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.cities;
    return widget.cities
        .where(
          (city) =>
              city.nameAr.toLowerCase().contains(query) ||
              city.nameEn.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cities = _filtered;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.78,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
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
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.selectCity.tr,
                    style: MarketplaceTypography.heroDisplay.copyWith(
                      fontSize: 23,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                border: Border.all(color: palette.hairline),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: palette.textMuted,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (value) => setState(() => _query = value),
                      cursorColor: palette.brand,
                      style: MarketplaceTypography.pillLabel.copyWith(
                        fontSize: 12.5,
                        color: palette.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: LocaleKeys.searchCity.tr,
                        hintStyle: MarketplaceTypography.pillLabel.copyWith(
                          fontSize: 12.5,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: cities.isEmpty
                ? Center(
                    child: Text(
                      LocaleKeys.noProducts.tr,
                      style: MarketplaceTypography.rowMeta.copyWith(
                        fontSize: 12,
                        color: palette.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: cities.length,
                    itemBuilder: (_, index) {
                      final city = cities[index];
                      final isSelected = city.id == widget.selectedId;
                      return GestureDetector(
                        onTap: () => Get.back(result: city),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: palette.hairline),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  city.name,
                                  style:
                                      MarketplaceTypography.rowTitle.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_rounded,
                                  size: 17,
                                  color: palette.brand,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
