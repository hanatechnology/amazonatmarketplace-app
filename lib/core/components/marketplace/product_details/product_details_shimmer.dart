import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import 'product_hero.dart';
import 'product_store_rail.dart';

/// Placeholder shaped like the real page — hero, chips, title, price, seller
/// card, description, spec tiles, rail and bottom bar — so nothing jumps when
/// the product lands. The named "loading product" line sits at the top of the
/// sheet so the state is stated, not merely implied.
class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key, this.gutter = 20});

  final double gutter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: palette.shimmerBase,
          highlightColor: palette.shimmerHighlight,
          child: Container(
            height: ProductHero.heightFor(context),
            width: double.infinity,
            color: palette.shimmerBase,
          ),
        ),
        Expanded(
          // The real page scrolls, and the hero is now a full-width 4:5 box —
          // tall enough that the skeleton beneath it no longer fits on a short
          // device. Clipped rather than scrollable: this is a placeholder, and
          // nothing in it rewards being reached.
          child: ClipRect(
            child: OverflowBox(
              alignment: AlignmentDirectional.topStart,
              maxHeight: double.infinity,
              child: Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: palette.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _LoadingLine(),
                      const SizedBox(height: 14),
                      Shimmer.fromColors(
                        baseColor: palette.shimmerBase,
                        highlightColor: palette.shimmerHighlight,
                        child: const _Skeleton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingLine extends StatelessWidget {
  const _LoadingLine();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        SizedBox(
          width: 13,
          height: 13,
          child: CircularProgressIndicator(
            strokeWidth: 1.8,
            color: palette.brand,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          LocaleKeys.loadingProduct.tr,
          style: MarketplaceTypography.rowMeta.copyWith(
            fontSize: 11,
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget bar(double width, double height, [double radius = 6]) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: palette.shimmerBase,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            bar(96, 22, MarketplaceRadius.full),
            const Spacer(),
            bar(64, 22, MarketplaceRadius.full),
          ],
        ),
        const SizedBox(height: 12),
        bar(double.infinity, 20),
        const SizedBox(height: 8),
        bar(210, 20),
        const SizedBox(height: 14),
        bar(140, 26),
        const SizedBox(height: 14),
        bar(double.infinity, 58, 18),
        const SizedBox(height: 14),
        bar(double.infinity, 11),
        const SizedBox(height: 7),
        bar(double.infinity, 11),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: bar(double.infinity, 46, 14)),
            const SizedBox(width: 8),
            Expanded(child: bar(double.infinity, 46, 14)),
            const SizedBox(width: 8),
            Expanded(child: bar(double.infinity, 46, 14)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(
                    ProductStoreRail.cardWidth,
                    ProductStoreRail.imageHeight,
                    14,
                  ),
                  const SizedBox(height: 6),
                  bar(ProductStoreRail.cardWidth, 10),
                  const SizedBox(height: 6),
                  bar(58, 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
