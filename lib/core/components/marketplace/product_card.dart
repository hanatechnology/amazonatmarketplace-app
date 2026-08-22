import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_shadows.dart';
import '../../theme/marketplace_icons.dart';
import 'app_network_image.dart';
import 'discount_badge.dart';
import 'star_rating.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.sellerName,
    required this.price,
    required this.rating,
    this.originalPrice,
    this.discountPercent,
    this.isWishlisted = false,
    required this.onTap,
    required this.onAddToCart,
    this.onWishlistToggle,
  });

  final String imageUrl;
  final String name;
  final String sellerName;
  final double price;
  final double rating;
  final double? originalPrice;
  final int? discountPercent;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback? onWishlistToggle;

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
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: MarketplaceSpacing.productCardWidth,
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          border: Border.all(color: MarketplaceColors.stroke, width: 1),
          boxShadow: const [MarketplaceShadows.cardElevation],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──────────────────────────────
            // Flexes so the info area below always keeps the height its fixed
            // content needs. The card's height comes from the grid's
            // childAspectRatio and so shrinks with the column width, while the
            // info content (2-line name, price, 36px button) does not — a
            // fixed-height image squeezed it until it overflowed on narrow
            // screens. The image absorbs the difference instead.
            Expanded(
              child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(MarketplaceRadius.cardImage),
                    child: AppNetworkImage(
                      imageUrl: widget.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                ),

                // Discount badge — top left
                if (widget.discountPercent != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: DiscountBadge(percentage: widget.discountPercent!),
                  ),

                // Wishlist heart — top right
                Positioned(
                  top: 10,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onWishlistToggle,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: MarketplaceColors.surface.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [MarketplaceShadows.activeTabIcon],
                      ),
                      child: Icon(
                        widget.isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: widget.isWishlisted
                            ? Colors.red
                            : MarketplaceColors.iconInactive,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),

            // ── Info area ───────────────────────────────
            // MainAxisSize.min: the image above takes the slack now, so this
            // sizes to its content instead of stretching.
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name + seller
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: MarketplaceTypography.cardTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.sellerName,
                          style: MarketplaceTypography.cardSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price + rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${widget.price.toStringAsFixed(2)}',
                              style: MarketplaceTypography.cardPrice,
                            ),
                            if (widget.originalPrice != null)
                              Text(
                                '\$${widget.originalPrice!.toStringAsFixed(2)}',
                                style: MarketplaceTypography.micro.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: MarketplaceColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        StarRating(
                          rating: widget.rating,
                          size: MarketplaceIcons.starSizeCard,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Add to Cart — 36px height (up from 28px for a11y)
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: _isAddingToCart ? null : _handleAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MarketplaceColors.primary,
                          foregroundColor: MarketplaceColors.onPrimary,
                          disabledBackgroundColor:
                              MarketplaceColors.primary.withOpacity(0.6),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              MarketplaceRadius.smallButton,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: _isAddingToCart
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: MarketplaceColors.onPrimary,
                                ),
                              )
                            : Text(
                                'Add to Cart',
                                style: MarketplaceTypography.smallButton,
                              ),
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
