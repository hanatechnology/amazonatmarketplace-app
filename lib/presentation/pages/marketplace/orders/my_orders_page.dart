import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/components/marketplace/orders/order_list_item.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../controllers/marketplace/orders_controller.dart';

/// Order history. Infinite scroll rather than the web's numbered pagination.
class MyOrdersPage extends GetView<OrdersController> {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(title: LocaleKeys.myOrders.tr),
      body: Obx(() {
        final state = controller.stateFor<List<OrderEntity>>(kOrders);
        return state.value.when(
          onInitial: () => const _OrdersLoading(),
          onLoading: () => const _OrdersLoading(),
          onSuccess: (orders, _) => _OrdersList(orders: orders),
          onError: (message, _) => _OrdersError(message: message),
        );
      }),
    );
  }
}

class _OrdersLoading extends StatelessWidget {
  const _OrdersLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: MarketplaceColors.primary),
    );
  }
}

class _OrdersList extends GetView<OrdersController> {
  const _OrdersList({required this.orders});

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshOrders,
        color: MarketplaceColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: MarketplaceSpacing.xxl),
            _OrdersEmpty(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshOrders,
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
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.screenPaddingH,
              vertical: MarketplaceSpacing.md,
            ),
            itemCount: orders.length + (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) =>
                const SizedBox(height: MarketplaceSpacing.sm),
            itemBuilder: (_, index) {
              if (index >= orders.length) {
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

              final order = orders[index];
              return OrderListItem(
                order: order,
                onTap: () => Get.toNamed(
                  Routes.MARKETPLACE_ORDER_DETAILS,
                  arguments: order.id,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty();

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
              Icons.receipt_long_outlined,
              size: 56,
              color: MarketplaceColors.primary,
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.lg),
          Text(
            LocaleKeys.noOrders.tr,
            style: MarketplaceTypography.sectionHeading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          Text(
            LocaleKeys.noOrdersDesc.tr,
            style: MarketplaceTypography.descriptionBody,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OrdersError extends GetView<OrdersController> {
  const _OrdersError({required this.message});

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
              onPressed: controller.refreshOrders,
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
