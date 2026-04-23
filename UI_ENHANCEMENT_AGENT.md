# UI/UX Enhancement Instructions — Marketplace App

> **IMPORTANT**: This is a coding agent instruction document. Follow every fix exactly.
> Apply in the order listed. Do NOT skip any item.
>
> **Source**: Design critique of Login + Home screens against Figma file `NO3iZ9gUb03kQWQELYob7F`
> **Severity**: 🔴 Critical (compile/crash risk) → 🟡 UX issue → 🟢 Polish

---

## Table of Contents

1. [Critical Fixes — Apply First](#1-critical-fixes--apply-first)
2. [Typography Token Additions](#2-typography-token-additions)
3. [Enhanced `product_card.dart`](#3-enhanced-product_carddart)
4. [Enhanced `category_chip.dart`](#4-enhanced-category_chipdart)
5. [Enhanced `promo_banner.dart`](#5-enhanced-promo_bannerdart)
6. [Enhanced `loading_shimmer.dart`](#6-enhanced-loading_shimmerdart)
7. [Enhanced `search_bar_widget.dart`](#7-enhanced-search_bar_widgetdart)
8. [Enhanced `marketplace_bottom_nav.dart`](#8-enhanced-marketplace_bottom_navdart)
9. [Enhanced Login Page](#9-enhanced-login-page)
10. [Enhanced Home Page Sections](#10-enhanced-home-page-sections)
11. [Accessibility Fixes](#11-accessibility-fixes)
12. [New Dependency Needed](#12-new-dependency-needed)

---

## 1. Critical Fixes — Apply First

### 1.1 🔴 Add missing `seeAll` typography + `white` color token

**MODIFY** `lib/core/theme/marketplace_typography.dart` — add before the closing `}`

```dart
  /// "See All" link — 14px Medium in primary green
  static const TextStyle seeAll = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500,
    color: MarketplaceColors.primary,
  );

  /// h4 alias (used in some pages) — maps to sectionHeading
  static TextStyle get h4 => sectionHeading;

  /// h5 alias — maps to body
  static TextStyle get h5 => body;
```

**MODIFY** `lib/core/theme/marketplace_colors.dart` — add before the closing `}`

```dart
  /// Pure white (alias for surface — used where 'white' is explicitly needed)
  static const Color white = Color(0xFFFFFFFF);
```

### 1.2 🔴 Fix `promo_banner.dart` — replace hardcoded color + fix CTA width

**REWRITE** `lib/core/components/marketplace/promo_banner.dart`

```dart
import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import 'app_network_image.dart';

/// Promotional banner — 343×146 from Figma.
/// Supports both local asset and network image URLs.
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imageUrl,
    required this.onCta,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imageUrl;   // network URL or local asset path
  final VoidCallback onCta;

  bool get _isNetworkImage =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MarketplaceSpacing.bannerHeight,
      decoration: BoxDecoration(
        color: MarketplaceColors.secondary,
        borderRadius: BorderRadius.circular(MarketplaceRadius.card),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // ── Left content ─────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: MarketplaceTypography.bannerTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: MarketplaceTypography.bannerSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // CTA — auto-width, not hardcoded 90px
                  TextButton(
                    onPressed: onCta,
                    style: TextButton.styleFrom(
                      backgroundColor: MarketplaceColors.primary,
                      foregroundColor: MarketplaceColors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MarketplaceRadius.bannerCta,
                        ),
                      ),
                    ),
                    child: Text(
                      ctaLabel,
                      style: MarketplaceTypography.bannerCta,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Right image ───────────────────────────────
          Expanded(
            flex: 2,
            child: _isNetworkImage
                ? AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
          ),
        ],
      ),
    );
  }
}
```

### 1.3 🔴 Fix OTP fields — add digit-only input formatter

**MODIFY** `lib/presentation/pages/marketplace/auth/verify_phone_page.dart`

Add import at the top:
```dart
import 'package:flutter/services.dart';
```

In the `TextField` for OTP (inside `List.generate`), add `inputFormatters`:
```dart
inputFormatters: [FilteringTextInputFormatter.digitsOnly],
```

---

## 2. Typography Token Additions

Already handled in §1.1 above. No additional changes needed.

---

## 3. Enhanced `product_card.dart`

**REWRITE** `lib/core/components/marketplace/product_card.dart`

Key improvements:
- Touch target for "Add to Cart" increased to 36px (up from 28px)
- Added pressed state via `InkWell` ripple
- Added per-card loading state for add-to-cart action
- Added wishlist button (heart icon, top-right)
- Used `MarketplaceRadius.cardImage` token instead of hardcoded 10

```dart
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
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(7),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.cardImage),
                    child: AppNetworkImage(
                      imageUrl: widget.imageUrl,
                      width: MarketplaceSpacing.productCardWidth - 14,
                      height: MarketplaceSpacing.productImageHeight,
                      fit: BoxFit.cover,
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
                  top: 8,
                  right: 8,
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

            // ── Info area ───────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                'Add to Cart', // Use LocaleKeys.addToCart.tr
                                style: MarketplaceTypography.smallButton,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

> **Note on translation**: Replace the `'Add to Cart'` string with `LocaleKeys.addToCart.tr` after adding the import for `locale_keys.dart`.

---

## 4. Enhanced `category_chip.dart`

**REWRITE** `lib/core/components/marketplace/category_chip.dart`

Improvements:
- Added `isSelected` state with primary border highlight
- Proper touch target (wraps with `InkWell` + ripple)
- Uses `MarketplaceRadius.cardImage` token

```dart
import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import 'app_network_image.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final String imageUrl;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MarketplaceSpacing.categoryChipWidth,
        child: Column(
          children: [
            // Image with selected border
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MarketplaceRadius.cardImage),
                border: Border.all(
                  color: isSelected
                      ? MarketplaceColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  MarketplaceRadius.cardImage - 2,
                ),
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  width: MarketplaceSpacing.categoryChipWidth,
                  height: MarketplaceSpacing.categoryImageHeight,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: MarketplaceTypography.cardSubtitle.copyWith(
                color: isSelected
                    ? MarketplaceColors.primary
                    : MarketplaceColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Enhanced `promo_banner.dart`

Already rewritten in §1.2 — skip.

---

## 6. Enhanced `loading_shimmer.dart`

**REWRITE** `lib/core/components/marketplace/loading_shimmer.dart`

Improvements:
- Uses `MarketplaceColors.stroke` instead of hardcoded `Colors.grey`
- RTL-safe shimmer direction
- Added `CategoryChipShimmer` (referenced in `home_page.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';

/// Base shimmer box — use instead of hardcoded grey containers
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({this.width, this.height, this.borderRadius});
  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MarketplaceColors.stroke.withOpacity(0.4),
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
    );
  }
}

/// Wraps children in a shimmer animation
class _ShimmerWrapper extends StatelessWidget {
  const _ShimmerWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MarketplaceColors.stroke.withOpacity(0.4),
      highlightColor: MarketplaceColors.stroke.withOpacity(0.15),
      child: child,
    );
  }
}

/// Matches ProductCard: 164×231
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: Container(
        width: MarketplaceSpacing.productCardWidth,
        height: MarketplaceSpacing.productCardHeight,
        decoration: BoxDecoration(
          color: MarketplaceColors.stroke.withOpacity(0.4),
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
        ),
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            _ShimmerBox(
              width: double.infinity,
              height: MarketplaceSpacing.productImageHeight,
              borderRadius: MarketplaceRadius.cardImage,
            ),
            const SizedBox(height: 8),
            // Name
            _ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
            const SizedBox(height: 4),
            // Seller
            _ShimmerBox(width: 80, height: 10, borderRadius: 4),
            const SizedBox(height: 8),
            // Price + button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ShimmerBox(width: 60, height: 12, borderRadius: 4),
                _ShimmerBox(width: 24, height: 12, borderRadius: 4),
              ],
            ),
            const Spacer(),
            // Button
            _ShimmerBox(
              width: double.infinity,
              height: 36,
              borderRadius: MarketplaceRadius.smallButton,
            ),
          ],
        ),
      ),
    );
  }
}

/// Matches CartItemCard: full-width × 110
class CartItemShimmer extends StatelessWidget {
  const CartItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: Container(
        height: MarketplaceSpacing.cartItemHeight,
        decoration: BoxDecoration(
          color: MarketplaceColors.stroke.withOpacity(0.4),
          borderRadius: BorderRadius.circular(MarketplaceRadius.cartItem),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Image
            _ShimmerBox(
              width: MarketplaceSpacing.cartImageWidth,
              height: MarketplaceSpacing.cartImageHeight,
              borderRadius: MarketplaceRadius.cardImage,
            ),
            const SizedBox(width: 12),
            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 100, height: 10, borderRadius: 4),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 60, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Matches PromoBanner: full-width × 146
class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: _ShimmerBox(
        width: double.infinity,
        height: MarketplaceSpacing.bannerHeight,
        borderRadius: MarketplaceRadius.card,
      ),
    );
  }
}

/// Matches CategoryChip: 74 × (71 image + 24 label)
class CategoryChipShimmer extends StatelessWidget {
  const CategoryChipShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(
      child: SizedBox(
        width: MarketplaceSpacing.categoryChipWidth,
        child: Column(
          children: [
            _ShimmerBox(
              width: MarketplaceSpacing.categoryChipWidth,
              height: MarketplaceSpacing.categoryImageHeight,
              borderRadius: MarketplaceRadius.cardImage,
            ),
            const SizedBox(height: 4),
            _ShimmerBox(width: 50, height: 10, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Enhanced `search_bar_widget.dart`

**REWRITE** `lib/core/components/marketplace/search_bar_widget.dart`

Improvements:
- 400ms debounce — prevents API call on every keystroke
- Clear (X) button appears when text is entered
- Proper focus state styling

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_icons.dart';
import '../../localization/locale_keys.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.onFilter,
    this.controller,
    this.hintText,
    this.debounceMs = 400,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback? onFilter;
  final TextEditingController? controller;
  final String? hintText;
  final int debounceMs;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);

    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onSearch(_controller.text.trim());
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Search field ────────────────────────────────
        Expanded(
          child: SizedBox(
            height: MarketplaceSpacing.searchBarHeight,
            child: TextField(
              controller: _controller,
              style: MarketplaceTypography.body,
              decoration: InputDecoration(
                hintText: widget.hintText ?? LocaleKeys.search.tr,
                hintStyle: MarketplaceTypography.inputPlaceholder,
                prefixIcon: const Icon(
                  MarketplaceIcons.search,
                  color: MarketplaceColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _hasText
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: MarketplaceColors.textSecondary,
                          size: 18,
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                  borderSide: const BorderSide(color: MarketplaceColors.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                  borderSide: const BorderSide(color: MarketplaceColors.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                  borderSide: const BorderSide(
                    color: MarketplaceColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: MarketplaceSpacing.md,
                ),
                filled: true,
                fillColor: MarketplaceColors.surface,
              ),
            ),
          ),
        ),

        // ── Filter button ────────────────────────────────
        if (widget.onFilter != null) ...[
          const SizedBox(width: MarketplaceSpacing.md),
          Semantics(
            label: 'Filter',
            button: true,
            child: GestureDetector(
              onTap: widget.onFilter,
              child: Container(
                width: MarketplaceSpacing.filterButtonSize,
                height: MarketplaceSpacing.filterButtonSize,
                decoration: BoxDecoration(
                  color: MarketplaceColors.surface,
                  border: Border.all(color: MarketplaceColors.stroke),
                  borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                ),
                child: const Icon(
                  MarketplaceIcons.filter,
                  color: MarketplaceColors.textBody,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

---

## 8. Enhanced `marketplace_bottom_nav.dart`

**REWRITE** `lib/core/components/marketplace/marketplace_bottom_nav.dart`

Improvements:
- Cart badge count overlay (pass `cartCount` from CartController)
- Haptic feedback on tab tap
- Proper `Semantics` for accessibility

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_shadows.dart';
import '../../theme/marketplace_icons.dart';
import '../../theme/marketplace_radius.dart';
import '../../../core/localization/locale_keys.dart';

class MarketplaceBottomNav extends StatelessWidget {
  const MarketplaceBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  final int currentIndex;
  final Function(int) onTap;
  final int cartCount;

  List<String> get _labels => [
        LocaleKeys.navHome.tr,
        LocaleKeys.navCategory.tr,
        LocaleKeys.navSeller.tr,
        LocaleKeys.navCart.tr,
        LocaleKeys.navAccount.tr,
      ];

  static const _outlinedIcons = [
    MarketplaceIcons.homeOutlined,
    MarketplaceIcons.categoryOutlined,
    MarketplaceIcons.sellerOutlined,
    MarketplaceIcons.cartOutlined,
    MarketplaceIcons.accountOutlined,
  ];

  static const _filledIcons = [
    MarketplaceIcons.homeFilled,
    MarketplaceIcons.categoryFilled,
    MarketplaceIcons.sellerFilled,
    MarketplaceIcons.cartFilled,
    MarketplaceIcons.accountFilled,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: MarketplaceRadius.bottomNavBR,
          boxShadow: const [MarketplaceShadows.bottomNav],
        ),
        child: Row(
          children: List.generate(5, (i) => _buildTab(i)),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final isActive = currentIndex == index;
    final color =
        isActive ? MarketplaceColors.primary : MarketplaceColors.iconInactive;
    final isCartTab = index == 3;

    return Expanded(
      child: Semantics(
        label: _labels[index],
        selected: isActive,
        button: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap(index);
          },
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional cart badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? _filledIcons[index] : _outlinedIcons[index],
                    color: color,
                    size: 24,
                  ),
                  // Cart badge
                  if (isCartTab && cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _labels[index],
                style: MarketplaceTypography.navLabel.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Update `main_navigation_page.dart`** to pass cart count:

```dart
// In _MainNavigationPageState.build(), update the bottomNavigationBar:
bottomNavigationBar: Obx(() => MarketplaceBottomNav(
  currentIndex: controller.currentIndex.value,
  cartCount: controller.cartItemCount.value,  // Add this
  onTap: (index) {
    if (controller.currentIndex.value == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    }
    controller.changePage(index);
  },
)),
```

**Update `main_navigation_controller.dart`**:

```dart
import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt cartItemCount = 0.obs;  // Add this

  void changePage(int index) {
    currentIndex.value = index;
  }

  /// Called by CartController when cart changes
  void updateCartCount(int count) {
    cartItemCount.value = count;
  }
}
```

---

## 9. Enhanced Login Page

**MODIFY** `lib/presentation/pages/marketplace/auth/marketplace_login_page.dart`

The page is well-structured. Apply these targeted changes only:

### 9.1 Move "Continue as Guest" below the Send OTP button

Replace the top-aligned `TextButton`:
```dart
// REMOVE this from top of Column:
Align(
  alignment: AlignmentDirectional.centerEnd,
  child: TextButton(
    onPressed: controller.continueAsGuest,
    child: Text(LocaleKeys.continueAsGuest.tr, ...),
  ),
),
```

Add BELOW the "Send OTP" `ElevatedButton`:
```dart
const SizedBox(height: MarketplaceSpacing.sm),

// Continue as Guest — secondary option, clearly visible
OutlinedButton(
  onPressed: controller.continueAsGuest,
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(double.infinity, MarketplaceSpacing.buttonHeight),
    side: const BorderSide(color: MarketplaceColors.stroke),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MarketplaceRadius.button),
    ),
  ),
  child: Text(
    LocaleKeys.continueAsGuest.tr,
    style: MarketplaceTypography.body.copyWith(
      color: MarketplaceColors.textBody,
    ),
  ),
),
```

### 9.2 Add brand illustration above app name

Add before the `Text(LocaleKeys.appName.tr, ...)`:
```dart
// Brand icon mark
Center(
  child: Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      color: MarketplaceColors.secondary,
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.shopping_bag_rounded,
      size: 36,
      color: MarketplaceColors.primary,
    ),
  ),
),
const SizedBox(height: MarketplaceSpacing.md),
```

### 9.3 Fix Terms text size

Change the `micro` style (10px) on Terms to `descriptionBody` (13px):
```dart
// Replace MarketplaceTypography.micro with:
MarketplaceTypography.descriptionBody.copyWith(
  color: MarketplaceColors.textSecondary,
)
// And for links:
MarketplaceTypography.descriptionBody.copyWith(
  color: MarketplaceColors.link,
  decoration: TextDecoration.underline,
)
```

---

## 10. Enhanced Home Page Sections

**MODIFY** `lib/presentation/pages/marketplace/home/home_page.dart`

### 10.1 Update `_SectionHeader` to use `seeAll` typography

```dart
// Replace in _SectionHeader.build():
GestureDetector(
  onTap: onSeeAll,
  child: Text(
    LocaleKeys.seeAll.tr,
    style: MarketplaceTypography.seeAll,  // Was: cardTitle.copyWith(...)
  ),
),
```

### 10.2 Add banner pause on user drag

In `_HomePageState`, add this field and update `initState`:
```dart
bool _userInteractingWithBanner = false;

// Update _startAutoScroll:
void _startAutoScroll() {
  _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
    if (_userInteractingWithBanner) return;  // Add this check
    if (_bannerController.hasClients && controller.banners.isNotEmpty) {
      final next = (_bannerController.page?.round() ?? 0) + 1;
      _bannerController.animateToPage(
        next % controller.banners.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  });
}
```

Wrap the `PageView.builder` with a `GestureDetector`:
```dart
GestureDetector(
  onPanDown: (_) => _userInteractingWithBanner = true,
  onPanEnd: (_) => _userInteractingWithBanner = false,
  onPanCancel: () => _userInteractingWithBanner = false,
  child: PageView.builder(
    controller: _bannerController,
    // ... rest unchanged
  ),
),
```

### 10.3 Add `CategoryChip` selected state support to home

In `_buildCategoryList()`, track the selected category:

Add to `_HomePageState`:
```dart
String? _selectedCategoryId;
```

Update the `CategoryChip` in `onSuccess`:
```dart
itemBuilder: (_, index) => CategoryChip(
  imageUrl: categories[index].imageUrl,
  label: categories[index].name,
  isSelected: _selectedCategoryId == categories[index].id,
  onTap: () {
    setState(() => _selectedCategoryId = categories[index].id);
    // TODO: Filter products by category
  },
),
```

---

## 11. Accessibility Fixes

### 11.1 Fix contrast — `textSecondary` (#898989 fails AA)

**MODIFY** `lib/core/theme/marketplace_colors.dart`:

```dart
// Change textSecondary from #898989 to #767676 (passes 4.5:1 AA ratio)
static const Color textSecondary = Color(0xFF767676);
```

> **Note**: `textMuted` (#A2A2A2) is fine for placeholder/decorative text only — it must never be used for meaningful label or body text. Its usage is already limited to `inputPlaceholder` and `bannerSubtitle` — both acceptable.

### 11.2 Add `Semantics` to icon-only buttons in `marketplace_app_bar.dart`

**MODIFY** `lib/core/components/marketplace/marketplace_app_bar.dart` — wrap the back `IconButton`:

```dart
// Replace the IconButton with:
Semantics(
  label: 'Go back',
  button: true,
  child: IconButton(
    icon: const Icon(MarketplaceIcons.backArrow),
    onPressed: onBack ?? () => Get.back(),
    color: MarketplaceColors.primary,
    iconSize: 20,
  ),
),
```

### 11.3 Add `FilteringTextInputFormatter` to OTP

Already covered in §1.3.

---

## 12. New Dependency Needed

If you want real Google/Apple SVG icons on the login page social buttons, add to `pubspec.yaml`:

```yaml
  flutter_svg: ^2.0.10+1
```

Then update `_SocialLoginButton` in `marketplace_login_page.dart`:

```dart
// Replace Icon(Icons.login) with:
SvgPicture.asset(
  iconPath,   // 'assets/icons/google.svg' or 'assets/icons/apple.svg'
  width: 20,
  height: 20,
),
```

Add the SVG assets to `assets/icons/` and declare them in `pubspec.yaml`:
```yaml
  assets:
    - assets/fonts/
    - assets/icons/
    - assets/images/   # ← add this for banner fallback images
```

---

## Summary — Files Modified

| File | Type | Changes |
|------|------|---------|
| `core/theme/marketplace_colors.dart` | Modify | Add `white`, fix `textSecondary` to #767676 |
| `core/theme/marketplace_typography.dart` | Modify | Add `seeAll`, `h4`, `h5` aliases |
| `core/components/marketplace/product_card.dart` | Rewrite | Wishlist, per-card loading, 36px button |
| `core/components/marketplace/category_chip.dart` | Rewrite | Selected state, animated border |
| `core/components/marketplace/promo_banner.dart` | Rewrite | Network image, auto-width CTA, token colors |
| `core/components/marketplace/loading_shimmer.dart` | Rewrite | Theme colors, `CategoryChipShimmer` |
| `core/components/marketplace/search_bar_widget.dart` | Rewrite | Debounce, clear button, semantics |
| `core/components/marketplace/marketplace_bottom_nav.dart` | Rewrite | Cart badge, haptic, semantics |
| `presentation/controllers/marketplace/main_navigation_controller.dart` | Modify | Add `cartItemCount` |
| `presentation/pages/marketplace/main_navigation_page.dart` | Modify | Pass `cartCount` to bottom nav |
| `presentation/pages/marketplace/auth/marketplace_login_page.dart` | Modify | Guest button position, illustration, terms text size |
| `presentation/pages/marketplace/auth/verify_phone_page.dart` | Modify | Add `digitsOnly` formatter to OTP |
| `presentation/pages/marketplace/home/home_page.dart` | Modify | `seeAll` type, banner pause, category selected state |
| `pubspec.yaml` | Modify | Add `flutter_svg`, add `assets/images/` |

---

*Apply in the order listed. Verify `flutter analyze` passes after each file group.*
