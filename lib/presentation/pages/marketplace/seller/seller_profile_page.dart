import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/product_card.dart';
import '../../../../core/components/marketplace/loading_shimmer.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_icons.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../domain/entities/marketplace/seller_entity.dart';
import '../../../controllers/marketplace/cart_controller.dart';
import '../../../controllers/marketplace/seller_profile_controller.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// One store: banner, identity, and its products.
///
/// No direct contact channel: the store's phone number is deliberately not part
/// of the customer payload, so orders and complaints run through the platform
/// rather than a private chat it cannot see.
class SellerProfilePage extends GetView<SellerProfileController> {
  const SellerProfilePage({super.key});

  static const double _gutter = 20.0;
  static const double _bannerHeight = 170.0;
  static const double _logoSize = 72.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Banner artwork runs under the status bar in both themes, so its glyphs
      // stay light; the scrim below guarantees they stay readable.
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: palette.background,
        body: StickyBackBar(
          tone: StickyBackTone.glass,
          child: Obx(() {
          final state = controller.stateFor<SellerEntity>(kSellerProfile);
          return state.value.when(
            onInitial: () => const _CenteredLoader(),
            onLoading: () => const _CenteredLoader(),
            onSuccess: (seller, _) => _SellerBody(seller: seller),
            onError: (message, _) => _SellerError(message: message),
          );
        })),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.palette.brand),
    );
  }
}

class _SellerBody extends GetView<SellerProfileController> {
  const _SellerBody({required this.seller});

  final SellerEntity seller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    // One Obx around the whole scroll view rather than per-sliver: Obx is a
    // plain widget, so it cannot sit in a `slivers` list.
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final productsState =
                controller.stateFor<List<ProductEntity>>(kSellerProducts).value;
            final isLoadingMore = controller.isLoadingMore.value;

            return RefreshIndicator(
              onRefresh: controller.refreshSellerProfile,
              color: palette.brand,
              backgroundColor: palette.surface,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  final metrics = scroll.metrics;
                  if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _SellerHeader(seller: seller)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SellerProfilePage._gutter,
                          18,
                          SellerProfilePage._gutter,
                          10,
                        ),
                        child: Text(
                          LocaleKeys.productsLabel.tr.toUpperCase(),
                          style: MarketplaceTypography.labelCaps.copyWith(
                            color: palette.textMuted,
                            letterSpacing:
                                MarketplaceTypography.isArabic ? 0 : 1.6,
                          ),
                        ),
                      ),
                    ),
                    productsState.when(
                      onInitial: () =>
                          const SliverToBoxAdapter(child: SizedBox.shrink()),
                      onLoading: () => const _ProductsGridShimmer(),
                      onSuccess: (products, _) =>
                          _ProductsGrid(products: products),
                      onError: (message, _) => SliverToBoxAdapter(
                        child: _ProductsError(message: message),
                      ),
                    ),
                    if (isLoadingMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: palette.brand,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: MarketplaceSpacing.md),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Full-bleed banner with the back control over it, then the store's identity.
class _SellerHeader extends StatelessWidget {
  const _SellerHeader({required this.seller});

  final SellerEntity seller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;
    final bannerHeight = SellerProfilePage._bannerHeight + topInset;
    final description = seller.description?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: bannerHeight + SellerProfilePage._logoSize / 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: bannerHeight,
                width: double.infinity,
                child: (seller.bannerUrl?.isNotEmpty ?? false)
                    ? AppNetworkImage(
                        imageUrl: seller.bannerUrl!,
                        width: double.infinity,
                        height: bannerHeight,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(color: palette.brandDeep),
              ),
              // Scrim, weighted to the top so the back button and status bar
              // stay readable over any photograph.
              IgnorePointer(
                child: SizedBox(
                  height: bannerHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          palette.scrim.withValues(alpha: 0.85),
                          palette.scrim.withValues(alpha: 0.28),
                          palette.scrim.withValues(alpha: 0.10),
                        ],
                        stops: const [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: SellerProfilePage._gutter,
                top: bannerHeight - SellerProfilePage._logoSize / 2,
                child: Container(
                  width: SellerProfilePage._logoSize,
                  height: SellerProfilePage._logoSize,
                  decoration: BoxDecoration(
                    color: palette.surfaceSunken,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: palette.background, width: 3),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: AppNetworkImage(
                    imageUrl: seller.logoUrl ?? '',
                    width: SellerProfilePage._logoSize,
                    height: SellerProfilePage._logoSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SellerProfilePage._gutter,
            10,
            SellerProfilePage._gutter,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seller.name,
                style: MarketplaceTypography.heroDisplay.copyWith(
                  fontSize: 27,
                  color: palette.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (seller.isVerified) ...[
                const SizedBox(height: 8),
                Container(
                  height: 24,
                  padding: const EdgeInsetsDirectional.only(start: 8, end: 11),
                  decoration: BoxDecoration(
                    color: palette.brand.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MarketplaceIcons.verified,
                        size: 14,
                        color: palette.brand,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        LocaleKeys.verified.tr,
                        style: MarketplaceTypography.pillLabel.copyWith(
                          fontSize: 11,
                          color: palette.brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  description,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 11.5,
                    height: 1.6,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductsGrid extends GetView<SellerProfileController> {
  const _ProductsGrid({required this.products});

  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(child: const _NoProducts());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: SellerProfilePage._gutter,
      ),
      sliver: SliverGrid.count(
        crossAxisCount: MarketplaceSpacing.productGridColumns,
        crossAxisSpacing: MarketplaceSpacing.productGridGap,
        mainAxisSpacing: MarketplaceSpacing.productGridGap,
        childAspectRatio: MarketplaceSpacing.productCardWidth /
            MarketplaceSpacing.productCardHeight,
        children: products
            .map((product) => ProductCard(
                  imageUrl: product.imageUrl,
                  name: product.name,
                  sellerName: product.sellerName,
                  price: product.price,
                  originalPrice: product.originalPrice,
                  discountPercent: product.discountPercent,
                  onTap: () => controller.openProduct(product),
                  onAddToCart: () async {
                    await Get.find<CartController>().addProduct(product, 1);
                  },
                ))
            .toList(),
      ),
    );
  }
}

class _ProductsGridShimmer extends StatelessWidget {
  const _ProductsGridShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: SellerProfilePage._gutter,
      ),
      sliver: SliverGrid.count(
        crossAxisCount: MarketplaceSpacing.productGridColumns,
        crossAxisSpacing: MarketplaceSpacing.productGridGap,
        mainAxisSpacing: MarketplaceSpacing.productGridGap,
        childAspectRatio: MarketplaceSpacing.productCardWidth /
            MarketplaceSpacing.productCardHeight,
        children: List.generate(4, (_) => const ProductCardShimmer()),
      ),
    );
  }
}

/// The store has no products yet.
class _NoProducts extends StatelessWidget {
  const _NoProducts();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.xl,
        vertical: MarketplaceSpacing.lg,
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: palette.textMuted,
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.md),
          Text(
            LocaleKeys.noStoreProducts.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 12,
              color: palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProductsError extends GetView<SellerProfileController> {
  const _ProductsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.xl,
        vertical: MarketplaceSpacing.lg,
      ),
      child: Column(
        children: [
          Text(
            message,
            style: MarketplaceTypography.body.copyWith(
              fontSize: 12,
              color: palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          TextButton(
            onPressed: controller.loadProducts,
            child: Text(
              LocaleKeys.retry.tr,
              style: MarketplaceTypography.body.copyWith(
                color: palette.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerError extends GetView<SellerProfileController> {
  const _SellerError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: MarketplaceTypography.body.copyWith(
                  color: palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              TextButton(
                onPressed: controller.refreshSellerProfile,
                child: Text(
                  LocaleKeys.retry.tr,
                  style: MarketplaceTypography.body.copyWith(
                    color: palette.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
