import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_icons.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../app_network_image.dart';

/// One store in the home "Featured stores" list.
///
/// The design's "Follow" action is a "View" action here: `GET /stores` exposes
/// no follow relation, and no rating or product count either — the supporting
/// line is the store's own description.
class HomeStoreRow extends StatelessWidget {
  const HomeStoreRow({
    super.key,
    required this.name,
    required this.logoUrl,
    required this.isVerified,
    required this.onTap,
    this.description,
    this.showDivider = true,
  });

  final String name;
  final String? logoUrl;
  final bool isVerified;
  final String? description;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final meta = (description == null || description!.trim().isEmpty)
        ? (isVerified ? LocaleKeys.verified.tr : null)
        : description!.trim();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(top: BorderSide(color: palette.hairline))
              : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 42,
                height: 42,
                color: palette.surfaceSunken,
                child: AppNetworkImage(
                  imageUrl: logoUrl ?? '',
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: MarketplaceTypography.rowTitle.copyWith(
                            color: palette.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 5),
                        Icon(
                          MarketplaceIcons.verified,
                          size: 13,
                          color: palette.brand,
                        ),
                      ],
                    ],
                  ),
                  if (meta != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      style: MarketplaceTypography.rowMeta.copyWith(
                        color: palette.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                border:
                    Border.all(color: palette.brand.withValues(alpha: 0.35)),
              ),
              child: Text(
                LocaleKeys.viewStore.tr,
                style: MarketplaceTypography.linkCaps.copyWith(
                  color: palette.brand,
                  letterSpacing: 0.6,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder row shown while stores load.
class HomeStoreRowShimmer extends StatelessWidget {
  const HomeStoreRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: palette.shimmerBase,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 11,
                    decoration: BoxDecoration(
                      color: palette.shimmerBase,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 90,
                    height: 9,
                    decoration: BoxDecoration(
                      color: palette.shimmerBase,
                      borderRadius: BorderRadius.circular(6),
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
