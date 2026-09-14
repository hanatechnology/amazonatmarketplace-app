import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/sellers/seller_card.dart';
import '../../../../core/components/marketplace/sellers/store_search_field.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/seller_entity.dart';
import '../../../controllers/marketplace/sellers_controller.dart';

/// Sellers tab. The API calls these "stores"; the UI keeps the "sellers" wording.
///
/// No filter or sort chips: `GET /stores` sorts by creation date only, and
/// filtering the pages already fetched would hide stores further down the list.
class SellersListPage extends GetView<SellersController> {
  const SellersListPage({super.key});

  static const double _gutter = 20.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.sellers.tr,
                    style: MarketplaceTypography.heroDisplay.copyWith(
                      fontSize: 30,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocaleKeys.sellersSubtitle.tr,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      fontSize: 11.5,
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  StoreSearchField(onSearch: controller.onSearch),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        SellersListPage._gutter,
        4,
        SellersListPage._gutter,
        MarketplaceSpacing.xxl + 40,
      ),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const SellerCardShimmer(),
    );
  }
}

class _SellersList extends GetView<SellersController> {
  const _SellersList({required this.sellers});

  final List<SellerEntity> sellers;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (sellers.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshSellers,
        color: palette.brand,
        backgroundColor: palette.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: MarketplaceSpacing.xl),
            _SellersEmpty(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshSellers,
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
        child: Obx(
          () => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              SellersListPage._gutter,
              4,
              SellersListPage._gutter,
              MarketplaceSpacing.xxl + 40,
            ),
            itemCount:
                sellers.length + (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, index) {
              if (index >= sellers.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.brand,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        LocaleKeys.loadingMoreSellers.tr,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 11.5,
                          color: palette.textMuted,
                        ),
                      ),
                    ],
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

/// Nothing matched. The query is quoted back so the customer can see what was
/// actually searched, with one way out.
class _SellersEmpty extends GetView<SellersController> {
  const _SellersEmpty();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final query = controller.searchQuery.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
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
              Icons.search_off_rounded,
              size: 34,
              color: palette.textMuted,
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.lg),
          Text(
            LocaleKeys.noSellers.tr,
            style: MarketplaceTypography.sectionDisplay.copyWith(
              color: palette.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          Text(
            query.isEmpty
                ? LocaleKeys.noSellersMessage.tr
                : '“$query” — ${LocaleKeys.noSellersMessage.tr}',
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 12,
              color: palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: MarketplaceSpacing.lg),
            GestureDetector(
              onTap: () => controller.onSearch(''),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                  border: Border.all(color: palette.hairline),
                ),
                child: Text(
                  LocaleKeys.clearSearch.tr,
                  style: MarketplaceTypography.pillLabel.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ),
          ],
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
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
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
              onPressed: controller.refreshSellers,
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
    );
  }
}
