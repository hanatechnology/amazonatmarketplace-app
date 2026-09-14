import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_icons.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

/// Home search affordance. Not a text field: tapping it opens the search
/// screen, where the live field and the filters already live.
class HomeSearchPill extends StatelessWidget {
  const HomeSearchPill({
    super.key,
    required this.onTap,
    required this.onFilterTap,
  });

  final VoidCallback onTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
        decoration: BoxDecoration(
          color: palette.surfaceSunken,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          border: Border.all(color: palette.hairline),
        ),
        child: Row(
          children: [
            Icon(MarketplaceIcons.search, size: 18, color: palette.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                LocaleKeys.searchHomeHint.tr,
                style: MarketplaceTypography.body.copyWith(
                  fontSize: 13,
                  color: palette.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onFilterTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.brand,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  MarketplaceIcons.filter,
                  size: 16,
                  color: palette.onBrand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
