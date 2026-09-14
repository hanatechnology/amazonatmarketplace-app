import 'package:flutter/material.dart';

import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../app_network_image.dart';

/// "More from this store" — the answer to a product page that cannot show
/// competing sellers, because a product has exactly one vendor.
///
/// Backed by `GET /products?vendor_id=`.
class ProductStoreRail extends StatelessWidget {
  const ProductStoreRail({
    super.key,
    required this.products,
    required this.onTapProduct,
    this.gutter = 20,
  });

  static const double cardWidth = 104;
  static const double imageHeight = 64;

  final List<ProductEntity> products;
  final ValueChanged<ProductEntity> onTapProduct;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 122,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.only(start: gutter, end: gutter),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) => _RailCard(
          product: products[index],
          onTap: () => onTapProduct(products[index]),
        ),
      ),
    );
  }
}

class _RailCard extends StatelessWidget {
  const _RailCard({required this.product, required this.onTap});

  final ProductEntity product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: ProductStoreRail.cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: ProductStoreRail.cardWidth,
              height: ProductStoreRail.imageHeight,
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.hardEdge,
              child: AppNetworkImage(
                imageUrl: product.imageUrl,
                width: ProductStoreRail.cardWidth,
                height: ProductStoreRail.imageHeight,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            // Fixed two-line box so the price lane stays level across cards
            // whether a name wraps once or twice.
            SizedBox(
              height: 28,
              child: Text(
                product.name,
                style: MarketplaceTypography.rowTitle.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: palette.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            _RailPrice(price: product.price),
          ],
        ),
      ),
    );
  }
}

/// Figure in the display serif, unit trailing it in the UI face — Latin digits
/// and left-to-right in Arabic too.
class _RailPrice extends StatelessWidget {
  const _RailPrice({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      textDirection: TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          PriceFormatter.amount(price),
          style: MarketplaceTypography.priceDisplay.copyWith(
            fontSize: 12.5,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          PriceFormatter.unit(),
          style: MarketplaceTypography.priceUnit.copyWith(
            fontSize: 8,
            color: palette.textMuted,
          ),
        ),
      ],
    );
  }
}
