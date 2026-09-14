import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../app_network_image.dart';

/// The store block from the product payload: logo, name, and the one link the
/// contract backs — the store's own page.
///
/// No verification tick, rating, follower count or Follow action: the product's
/// `vendor` summary carries none of them, and inventing them here would put a
/// claim on screen the API never made.
class ProductSellerCard extends StatelessWidget {
  const ProductSellerCard({
    super.key,
    required this.name,
    required this.logoUrl,
    required this.onTap,
  });

  final String name;
  final String logoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: AppNetworkImage(
                imageUrl: logoUrl,
                width: 38,
                height: 38,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.seller.tr.toUpperCase(),
                    style: MarketplaceTypography.labelCaps.copyWith(
                      fontSize: 9,
                      color: palette.textMuted,
                      letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              LocaleKeys.viewStore.tr,
              style: MarketplaceTypography.pillLabel.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: palette.brand,
                letterSpacing: 0,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: palette.brand,
            ),
          ],
        ),
      ),
    );
  }
}
