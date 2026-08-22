import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/components/marketplace/product_card.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_icons.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/product_entity.dart';
import '../../../../domain/entities/marketplace/seller_entity.dart';
import '../../../controllers/marketplace/seller_profile_controller.dart';

class SellerProfilePage extends GetView<SellerProfileController> {
  const SellerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(title: LocaleKeys.sellers.tr),
      body: Obx(() {
        final state = controller.stateFor<SellerEntity>(kSellerProfile);
        return state.value.when(
          onInitial: () => const _CenteredLoader(),
          onLoading: () => const _CenteredLoader(),
          onSuccess: (seller, _) => _SellerBody(seller: seller),
          onError: (message, _) => _SellerError(message: message),
        );
      }),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: MarketplaceColors.primary),
    );
  }
}

class _SellerBody extends GetView<SellerProfileController> {
  const _SellerBody({required this.seller});

  final SellerEntity seller;

  @override
  Widget build(BuildContext context) {
    // One Obx around the whole scroll view rather than per-sliver: Obx is a
    // plain widget, so it cannot sit in a `slivers` list.
    return Obx(() {
      final productsState =
          controller.stateFor<List<ProductEntity>>(kSellerProducts).value;
      final isLoadingMore = controller.isLoadingMore.value;

      return RefreshIndicator(
        onRefresh: controller.refreshSellerProfile,
        color: MarketplaceColors.primary,
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
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.md,
                    MarketplaceSpacing.screenPaddingH,
                    MarketplaceSpacing.sm,
                  ),
                  child: Text(
                    LocaleKeys.storeProducts.tr,
                    style: MarketplaceTypography.sectionHeading,
                  ),
                ),
              ),
              productsState.when(
                onInitial: () =>
                    const SliverToBoxAdapter(child: _InlineLoader()),
                onLoading: () =>
                    const SliverToBoxAdapter(child: _InlineLoader()),
                onSuccess: (products, _) => products.isEmpty
                    ? const SliverToBoxAdapter(child: _NoProducts())
                    : _ProductsGrid(products: products),
                onError: (message, _) => SliverToBoxAdapter(
                  child: _SellerError(message: message),
                ),
              ),
              SliverToBoxAdapter(
                child: isLoadingMore
                    ? const _InlineLoader()
                    : const SizedBox(height: MarketplaceSpacing.xl),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SellerHeader extends StatelessWidget {
  const _SellerHeader({required this.seller});

  final SellerEntity seller;

  static const double _bannerHeight = 140;
  static const double _logoSize = 72;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The logo overhangs the banner, so the stack may overflow and the
        // block below reserves half the logo's height.
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: _bannerHeight,
              width: double.infinity,
              color: MarketplaceColors.secondary,
              child: seller.bannerUrl == null
                  ? null
                  : AppNetworkImage(
                      imageUrl: seller.bannerUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
            PositionedDirectional(
              start: MarketplaceSpacing.screenPaddingH,
              bottom: -_logoSize / 2,
              child: Container(
                width: _logoSize,
                height: _logoSize,
                decoration: BoxDecoration(
                  color: MarketplaceColors.surface,
                  borderRadius: BorderRadius.circular(MarketplaceRadius.md),
                  border:
                      Border.all(color: MarketplaceColors.surface, width: 3),
                ),
                clipBehavior: Clip.antiAlias,
                child: seller.logoUrl != null
                    ? AppNetworkImage(
                        imageUrl: seller.logoUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: MarketplaceColors.secondary,
                        alignment: Alignment.center,
                        child: Text(
                          seller.name.isEmpty
                              ? '?'
                              : seller.name.substring(0, 1).toUpperCase(),
                          style: MarketplaceTypography.screenTitle.copyWith(
                            color: MarketplaceColors.primary,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MarketplaceSpacing.screenPaddingH,
            _logoSize / 2 + MarketplaceSpacing.sm,
            MarketplaceSpacing.screenPaddingH,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      seller.name,
                      style: MarketplaceTypography.sectionHeading,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (seller.isVerified) ...[
                    const SizedBox(width: MarketplaceSpacing.xs),
                    const Icon(
                      MarketplaceIcons.verified,
                      size: 18,
                      color: MarketplaceColors.successContent,
                    ),
                  ],
                ],
              ),
              if (seller.description != null &&
                  seller.description!.isNotEmpty) ...[
                const SizedBox(height: MarketplaceSpacing.xs),
                Text(
                  seller.description!,
                  style: MarketplaceTypography.descriptionBody,
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
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.screenPaddingH,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MarketplaceSpacing.productGridColumns,
          mainAxisSpacing: MarketplaceSpacing.productGridGap,
          crossAxisSpacing: MarketplaceSpacing.productGridGap,
          childAspectRatio: MarketplaceSpacing.productCardWidth /
              MarketplaceSpacing.productCardHeight,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            final product = products[index];
            return ProductCard(
              imageUrl: product.imageUrl,
              name: product.name,
              sellerName: product.sellerName,
              price: product.price,
              rating: product.rating,
              originalPrice: product.originalPrice,
              discountPercent: product.discountPercent,
              onTap: () => controller.openProduct(product),
              onAddToCart: () {},
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}

class _InlineLoader extends StatelessWidget {
  const _InlineLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(MarketplaceSpacing.lg),
      child: Center(
        child: SizedBox(
          width: MarketplaceSpacing.lg,
          height: MarketplaceSpacing.lg,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: MarketplaceColors.primary,
          ),
        ),
      ),
    );
  }
}

class _NoProducts extends StatelessWidget {
  const _NoProducts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MarketplaceSpacing.xl),
      child: Text(
        LocaleKeys.noStoreProducts.tr,
        style: MarketplaceTypography.descriptionBody,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SellerError extends GetView<SellerProfileController> {
  const _SellerError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MarketplaceSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: MarketplaceTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.sm),
            TextButton(
              onPressed: controller.refreshSellerProfile,
              child: Text(
                LocaleKeys.retry.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  color: MarketplaceColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
