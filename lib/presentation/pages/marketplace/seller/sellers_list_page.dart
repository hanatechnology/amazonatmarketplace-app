import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/components/marketplace/search_bar_widget.dart';
import '../../../../core/components/marketplace/sellers/seller_card.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/seller_entity.dart';
import '../../../controllers/marketplace/sellers_controller.dart';

/// Sellers tab. The API calls these "stores"; the UI keeps the "sellers" wording.
class SellersListPage extends GetView<SellersController> {
  const SellersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MarketplaceSpacing.screenPaddingH,
                MarketplaceSpacing.md,
                MarketplaceSpacing.screenPaddingH,
                MarketplaceSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.sellers.tr,
                    style: MarketplaceTypography.screenTitle,
                  ),
                  const SizedBox(height: MarketplaceSpacing.sm),
                  SearchBarWidget(
                    hintText: LocaleKeys.searchSellers.tr,
                    onSearch: controller.onSearch,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final state = controller.stateFor<List<SellerEntity>>(kSellers);
                return state.value.when(
                  onInitial: () => const _SellersLoading(),
                  onLoading: () => const _SellersLoading(),
                  onSuccess: (sellers, _) => _SellersList(sellers: sellers),
                  onError: (message, _) => _SellersError(message: message),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellersLoading extends StatelessWidget {
  const _SellersLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: MarketplaceColors.primary),
    );
  }
}

class _SellersList extends GetView<SellersController> {
  const _SellersList({required this.sellers});

  final List<SellerEntity> sellers;

  @override
  Widget build(BuildContext context) {
    if (sellers.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshSellers,
        color: MarketplaceColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: MarketplaceSpacing.xxl),
            _SellersEmpty(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshSellers,
      color: MarketplaceColors.primary,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          final metrics = scroll.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            controller.loadMore();
          }
          return false;
        },
        child: Obx(
          () => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              MarketplaceSpacing.screenPaddingH,
              0,
              MarketplaceSpacing.screenPaddingH,
              MarketplaceSpacing.md,
            ),
            itemCount: sellers.length + (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) =>
                const SizedBox(height: MarketplaceSpacing.md),
            itemBuilder: (_, index) {
              if (index >= sellers.length) {
                return const Padding(
                  padding: EdgeInsets.all(MarketplaceSpacing.md),
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

              final seller = sellers[index];
              return SellerCard(
                seller: seller,
                onTap: () => controller.openSeller(seller),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SellersEmpty extends StatelessWidget {
  const _SellersEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: MarketplaceColors.secondary.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 56,
              color: MarketplaceColors.primary,
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.lg),
          Text(
            LocaleKeys.noSellers.tr,
            style: MarketplaceTypography.sectionHeading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          Text(
            LocaleKeys.noSellersMessage.tr,
            style: MarketplaceTypography.descriptionBody,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SellersError extends GetView<SellersController> {
  const _SellersError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
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
              onPressed: controller.refreshSellers,
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
