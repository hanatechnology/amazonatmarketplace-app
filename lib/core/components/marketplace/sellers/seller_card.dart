import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_icons.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/seller_entity.dart';
import '../app_network_image.dart';

/// One store in the sellers list.
///
/// Banner strip, logo overlapping it, name + verified tick, two lines of the
/// store's own description. No rating, product count or follower line — the
/// store payload carries none of those, and inventing them would be a lie.
class SellerCard extends StatelessWidget {
  const SellerCard({super.key, required this.seller, required this.onTap});

  final SellerEntity seller;
  final VoidCallback onTap;

  static const double _bannerHeight = 60;
  static const double _logoSize = 42;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final description = seller.description?.trim() ?? '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.hairline),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _bannerHeight + _logoSize / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Banner, falling back to the lime wash when the store has
                  // not uploaded one.
                  SizedBox(
                    height: _bannerHeight,
                    width: double.infinity,
                    child: (seller.bannerUrl?.isNotEmpty ?? false)
                        ? AppNetworkImage(
                            imageUrl: seller.bannerUrl!,
                            width: double.infinity,
                            height: _bannerHeight,
                            fit: BoxFit.cover,
                          )
                        : ColoredBox(
                            color: palette.accent.withValues(
                              alpha: palette.isDark ? 0.18 : 0.55,
                            ),
                          ),
                  ),
                  PositionedDirectional(
                    start: 14,
                    top: _bannerHeight - _logoSize / 2 - 2,
                    child: Container(
                      width: _logoSize,
                      height: _logoSize,
                      decoration: BoxDecoration(
                        color: palette.surfaceSunken,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: palette.surface, width: 2.5),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: AppNetworkImage(
                        imageUrl: seller.logoUrl ?? '',
                        width: _logoSize,
                        height: _logoSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          seller.name,
                          style: MarketplaceTypography.rowTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (seller.isVerified) ...[
                        const SizedBox(width: 5),
                        Icon(
                          MarketplaceIcons.verified,
                          size: 14,
                          color: palette.brand,
                        ),
                      ],
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: MarketplaceTypography.rowMeta.copyWith(
                        fontSize: 11,
                        height: 1.6,
                        color: palette.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        LocaleKeys.viewStore.tr.toUpperCase(),
                        style: MarketplaceTypography.linkCaps.copyWith(
                          color: palette.brand,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: palette.brand,
                      ),
                    ],
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

/// Placeholder shaped like [SellerCard] — banner block, logo square, title and
/// description bars — rather than a bare spinner.
class SellerCardShimmer extends StatelessWidget {
  const SellerCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: palette.shimmerBase,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.hairline),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: SellerCard._bannerHeight,
              width: double.infinity,
              color: palette.shimmerBase,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: SellerCard._logoSize,
                        height: SellerCard._logoSize,
                        decoration: BoxDecoration(
                          color: palette.shimmerBase,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      bar(120, 12),
                    ],
                  ),
                  const SizedBox(height: 12),
                  bar(double.infinity, 9),
                  const SizedBox(height: 6),
                  bar(180, 9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
