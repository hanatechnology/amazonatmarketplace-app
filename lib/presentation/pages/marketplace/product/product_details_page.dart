import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import 'product_gallery_page.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/product_details/product_add_to_cart_bar.dart';
import '../../../../core/components/marketplace/product_details/product_details_shimmer.dart';
import '../../../../core/components/marketplace/product_details/product_hero.dart';
import '../../../../core/components/marketplace/product_details/product_not_found_view.dart';
import '../../../../core/components/marketplace/product_details/product_seller_card.dart';
import '../../../../core/components/marketplace/product_details/product_spec_tiles.dart';
import '../../../../core/components/marketplace/product_details/product_store_rail.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/status_tone.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/product_details_entity.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../controllers/marketplace/product_details_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// One product, drawn from `GET /products/{id}` and nothing else.
///
/// Everything the contract does not carry is absent by design: no rating, no
/// reviews, no discount, no competing sellers, no favourite. What replaces the
/// "other sellers" idea is the store's own rail — a product has exactly one
/// vendor, so the only sideways move available is the rest of that store.
class ProductDetailsPage extends GetView<ProductDetailsController> {
  const ProductDetailsPage({super.key});

  static const double gutter = 20;

  /// How far the content sheet rides up over the hero.
  static const double _sheetOverlap = 26;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The hero photograph runs under the status bar in both themes, so its
      // glyphs stay light; the scrim keeps them readable.
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: palette.background,
        body: StickyBackBar(
          tone: StickyBackTone.glass,
          child: Obx(() {
          final state = controller
              .stateFor<ProductDetailsEntity>(ProductDetailsController.kProduct)
              .value;

          return state.when(
            onInitial: () => const ProductDetailsShimmer(gutter: gutter),
            onLoading: () => const ProductDetailsShimmer(gutter: gutter),
            onSuccess: (product, _) => _ProductBody(product: product),
            onError: (message, _) => ProductNotFoundView(
              isNotFound: controller.isNotFound.value,
              message: message,
              onBrowse: controller.browseProducts,
              onRetry: controller.refresh,
            ),
          );
        })),
        bottomNavigationBar: Obx(() {
          final product = controller.getOperationData<ProductDetailsEntity>(
            ProductDetailsController.kProduct,
          );
          if (product == null) return const SizedBox.shrink();

          return ProductAddToCartBar(
            quantity: controller.quantity.value,
            isAvailable: product.isActive,
            isAdding: controller.isAddingToCart.value,
            onIncrement: controller.increment,
            onDecrement: controller.decrement,
            onAddToCart: controller.addToCart,
          );
        }),
      ),
    );
  }
}

class _ProductBody extends GetView<ProductDetailsController> {
  const _ProductBody({required this.product});

  final ProductDetailsEntity product;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final images = product.imageUrls.isNotEmpty
        ? product.imageUrls
        : <String>[if (product.imageUrl.isNotEmpty) product.imageUrl];

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: palette.brand,
      backgroundColor: palette.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => ProductHero(
                imageUrls: images,
                activeIndex: controller.activeImageIndex.value,
                onPageChanged: controller.onImageChanged,
                isAvailable: product.isActive,
                featuredLabel: _featuredLabel(product),
                onImageTap: (index) => Get.toNamed(
                  Routes.MARKETPLACE_PRODUCT_GALLERY,
                  arguments: ProductGalleryArgs(
                    images: images,
                    initialIndex: index,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -ProductDetailsPage._sheetOverlap),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.only(top: 16),
                child: _Sheet(product: product),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `featured_section` is one of three documented values; anything else the
  /// backend adds later goes unlabelled rather than shown raw.
  String? _featuredLabel(ProductDetailsEntity product) {
    if (!product.isFeatured) return null;
    switch (product.featuredSection) {
      case 'NEW_ARRIVALS':
        return LocaleKeys.newArrivals.tr;
      case 'BEST_SELLERS':
        return LocaleKeys.bestSellers.tr;
      case 'ADMIN_PICKS':
        return LocaleKeys.adminPicks.tr;
      default:
        return null;
    }
  }
}

class _Sheet extends GetView<ProductDetailsController> {
  const _Sheet({required this.product});

  final ProductDetailsEntity product;

  @override
  Widget build(BuildContext context) {
    const gutter = ProductDetailsPage.gutter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopRow(product: product),
              const SizedBox(height: 9),
              Text(
                product.name,
                style: MarketplaceTypography.heroDisplay.copyWith(
                  fontSize: MarketplaceTypography.isArabic ? 22 : 25,
                  color: product.isActive
                      ? context.palette.textPrimary
                      : context.palette.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _PriceRow(price: product.price, isAvailable: product.isActive),
              const SizedBox(height: 11),
              if (product.vendor.id.isNotEmpty)
                ProductSellerCard(
                  name: product.vendor.name,
                  logoUrl: product.vendor.logoUrl,
                  onTap: controller.openStore,
                ),
              const SizedBox(height: 11),
              if (product.isActive)
                _Description(text: product.description)
              else
                const _UnavailableNote(),
              const SizedBox(height: 12),
              ProductSpecTiles(
                weight: product.weight,
                sku: product.sku,
                createdAt: product.createdAt,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _StoreRailSection(product: product),
        const SizedBox(height: MarketplaceSpacing.lg),
      ],
    );
  }
}

/// Category chip and stock pill share a line: one says where the product sits
/// in the catalogue, the other whether it can be bought at all.
class _TopRow extends GetView<ProductDetailsController> {
  const _TopRow({required this.product});

  final ProductDetailsEntity product;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        if (product.category.name.isNotEmpty)
          Flexible(
            child: GestureDetector(
              onTap: controller.openCategory,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceSunken,
                  borderRadius:
                      BorderRadius.circular(MarketplaceRadius.full),
                  border: Border.all(color: palette.hairline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 11,
                      color: palette.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        product.category.name,
                        style: MarketplaceTypography.pillLabel.copyWith(
                          fontSize: 10,
                          color: palette.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const Spacer(),
        const SizedBox(width: 8),
        _StockPill(isAvailable: product.isActive),
      ],
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;
    final tone = isAvailable ? StatusTone.success : StatusTone.warning;

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: tone.background(isDark),
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAvailable) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: tone.foreground(isDark),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            (isAvailable ? LocaleKeys.inStock.tr : LocaleKeys.outOfStock.tr)
                .toUpperCase(),
            style: MarketplaceTypography.labelCaps.copyWith(
              color: tone.foreground(isDark),
              letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.9,
            ),
          ),
        ],
      ),
    );
  }
}

/// Figure in the display serif, currency trailing it — Latin digits and
/// left-to-right in Arabic too.
class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price, required this.isAvailable});

  final double price;
  final bool isAvailable;

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
            fontSize: 29,
            color: isAvailable ? palette.textPrimary : palette.textSecondary,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          PriceFormatter.unit(),
          style: MarketplaceTypography.priceUnit.copyWith(
            fontSize: 11,
            color: palette.textMuted,
          ),
        ),
      ],
    );
  }
}

class _Description extends GetView<ProductDetailsController> {
  const _Description({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.description.tr.toUpperCase(),
          style: MarketplaceTypography.labelCaps.copyWith(
            fontSize: 10,
            color: palette.textMuted,
            letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.9,
          ),
        ),
        const SizedBox(height: 5),
        Obx(() {
          final isExpanded = controller.isDescriptionExpanded.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                maxLines: isExpanded ? null : 2,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11.5,
                  height: 1.72,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: controller.toggleDescription,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  isExpanded
                      ? LocaleKeys.readLess.tr
                      : LocaleKeys.readMore.tr,
                  style: MarketplaceTypography.pillLabel.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: palette.brand,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

/// Replaces the description when the product cannot be ordered. It offers the
/// two recoveries that exist — the store's other products, and coming back.
class _UnavailableNote extends StatelessWidget {
  const _UnavailableNote();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: StatusTone.warning.background(isDark),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: StatusTone.warning.foreground(isDark),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              LocaleKeys.outOfStockNote.tr,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11,
                height: 1.65,
                color: StatusTone.warning.foreground(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "More from this store" — and, when the product itself cannot be bought,
/// "Available now from this store", which is the whole point of the rail then.
class _StoreRailSection extends GetView<ProductDetailsController> {
  const _StoreRailSection({required this.product});

  final ProductDetailsEntity product;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final state = controller
          .stateFor<List<ProductEntity>>(
            ProductDetailsController.kStoreProducts,
          )
          .value;

      return state.when(
        onInitial: () => const SizedBox.shrink(),
        onLoading: () => const SizedBox.shrink(),
        onError: (_, __) => const SizedBox.shrink(),
        onSuccess: (products, _) {
          if (products.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ProductDetailsPage.gutter,
                  0,
                  ProductDetailsPage.gutter,
                  8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (product.isActive
                                ? LocaleKeys.moreFromStore.tr
                                : LocaleKeys.availableNowStore.tr)
                            .toUpperCase(),
                        style: MarketplaceTypography.labelCaps.copyWith(
                          fontSize: 10,
                          color: palette.textMuted,
                          letterSpacing:
                              MarketplaceTypography.isArabic ? 0 : 0.9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.openStore,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        LocaleKeys.seeAll.tr,
                        style: MarketplaceTypography.pillLabel.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: palette.brand,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ProductStoreRail(
                products: products,
                onTapProduct: controller.openProduct,
                gutter: ProductDetailsPage.gutter,
              ),
            ],
          );
        },
      );
    });
  }
}
