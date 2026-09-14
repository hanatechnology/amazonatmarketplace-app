import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../localization/locale_keys.dart';
import '../../theme/marketplace_icons.dart';
import '../../theme/marketplace_palette.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_typography.dart';
import '../../utils/price_formatter.dart';

/// A product in a grid.
///
/// The photo plate *is* the card: there is no surface, border or shadow drawn
/// around the whole thing, and the name, seller and price sit directly on the
/// page ground. That is the same treatment the home rail card uses, so the two
/// product surfaces in the app finally read as one.
///
/// Two things this deliberately does not show, because the API cannot back
/// them: a star rating (`ProductModel` hard-codes `rating: 0` — the products
/// payload carries no rating field) and a wishlist heart (there is no
/// favourites endpoint). An affordance that cannot persist is worse than none.
class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.sellerName,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.onTap,
    required this.onAddToCart,
  });

  final String imageUrl;
  final String name;
  final String sellerName;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isAddingToCart = false;

  Future<void> _handleAddToCart() async {
    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);
    widget.onAddToCart();
    // Brief feedback delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isAddingToCart = false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The plate flexes. The grid hands the card a height derived from
          // `productCardWidth / productCardHeight`, and the real column width
          // rarely matches that exactly — so the plate absorbs the difference
          // rather than the fixed info block below being squeezed until it
          // overflows.
          Expanded(
            child: _PhotoPlate(
              imageUrl: widget.imageUrl,
              discountPercent: widget.discountPercent,
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: MarketplaceSpacing.productCardNameHeight,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                widget.name,
                style: MarketplaceTypography.cardHeading.copyWith(
                  color: palette.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),

          SizedBox(
            height: MarketplaceSpacing.productCardSellerHeight,
            child: Row(
              children: [
                // A storefront depicts; it does not point. It stays as-is in
                // both directions.
                Icon(
                  MarketplaceIcons.sellerOutlined,
                  size: 11,
                  color: palette.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.sellerName,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      color: palette.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),

          SizedBox(
            height: MarketplaceSpacing.productCardAddRowHeight,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text.rich(
                          // Figures and the currency token read left-to-right
                          // in both locales.
                          textDirection: TextDirection.ltr,
                          TextSpan(
                            text: PriceFormatter.amount(widget.price),
                            style: MarketplaceTypography.priceDisplay.copyWith(
                              color: palette.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: ' ${PriceFormatter.unit()}',
                                style: MarketplaceTypography.priceUnit.copyWith(
                                  color: palette.textMuted,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.originalPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          PriceFormatter.amount(widget.originalPrice!),
                          textDirection: TextDirection.ltr,
                          style: MarketplaceTypography.rowMeta.copyWith(
                            fontSize: 9.5,
                            color: palette.textMuted,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: palette.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ],
                    ],
                  ),
                ),
                _AddButton(
                  isBusy: _isAddingToCart,
                  onTap: _handleAddToCart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The photo, and everything drawn on top of it.
class _PhotoPlate extends StatelessWidget {
  const _PhotoPlate({required this.imageUrl, this.discountPercent});

  final String imageUrl;
  final int? discountPercent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(MarketplaceRadius.productPlate),
        border: Border.all(color: palette.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!hasImage)
            _MissingPhoto(palette: palette)
          else ...[
            _BlurFill(imageUrl: imageUrl, isDark: palette.isDark),
            Padding(
              padding: const EdgeInsets.all(
                MarketplaceSpacing.productCardImagePadding,
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                // The plate already reads as a photo slot while it loads, so a
                // second shimmer on top of it is just noise.
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) => _MissingPhoto(palette: palette),
              ),
            ),
          ],
          if (discountPercent != null && discountPercent! > 0)
            PositionedDirectional(
              bottom: 8,
              start: 8,
              child: _DiscountPill(percent: discountPercent!),
            ),
        ],
      ),
    );
  }
}

/// The same photograph, blurred and scaled to cover, behind the sharp one.
///
/// Vendors upload at every ratio. Laying the sharp photo in with `contain`
/// means nothing is ever cropped off a rug or a bowl — but on a 4:5 plate a
/// landscape shot then leaves two dead bands. Filling them with the picture's
/// own colours keeps the plate whole without touching the product.
class _BlurFill extends StatelessWidget {
  const _BlurFill({required this.imageUrl, required this.isDark});

  final String imageUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      // `clamp` extends the edge pixels outward. `decal` would fade them to
      // transparent and let the plate's surface colour bleed back in at the
      // very edge, which is the band we are trying to remove.
      imageFilter: ui.ImageFilter.blur(
        sigmaX: 18,
        sigmaY: 18,
        tileMode: TileMode.clamp,
      ),
      child: Opacity(
        // Dark mode needs less: the same wash reads twice as loud against ink.
        opacity: isDark ? 0.24 : 0.36,
        child: Transform.scale(
          scale: 1.12,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto({required this.palette});

  final MarketplacePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.surfaceSunken,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 22,
        color: palette.textMuted,
      ),
    );
  }
}

/// `-14%`, not the word "SALE".
///
/// `discount_percent` is already on the entity, so the card can say how much
/// rather than leaving the customer to open the product to find out.
class _DiscountPill extends StatelessWidget {
  const _DiscountPill({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
      ),
      // A percentage is a figure: Latin digits, left to right, and the minus
      // stays in front of them in Arabic too.
      child: Text(
        '-$percent%',
        textDirection: TextDirection.ltr,
        style: MarketplaceTypography.rowMeta.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.0,
          color: palette.onAccent,
        ),
      ),
    );
  }
}

/// Replaces the full-width "Add to cart" button.
///
/// That button spent 42pt of card height on a label the icon carries, and its
/// width was dictated by the English string — Arabic runs ~30% longer, so the
/// card floor was being set by the wrong language. The painted circle is 36;
/// the gesture box around it is 40×44 so the tap target clears the platform
/// minimum without the circle overhanging the card edge.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.isBusy, required this.onTap});

  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      enabled: !isBusy,
      label: LocaleKeys.addToCart.tr,
      child: GestureDetector(
        onTap: isBusy ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 40,
          height: MarketplaceSpacing.productCardAddRowHeight,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isBusy
                    ? palette.brand.withValues(alpha: 0.6)
                    : palette.brand,
              ),
              child: isBusy
                  ? SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.onBrand,
                      ),
                    )
                  : Icon(
                      MarketplaceIcons.plus,
                      size: 18,
                      color: palette.onBrand,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
