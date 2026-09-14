import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/orders/order_list_item.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../controllers/marketplace/orders_controller.dart';

/// Order history. Infinite scroll rather than the web's numbered pagination.
///
/// No status filter row: `GET /orders` takes page and limit only, so filtering
/// would apply to the pages already fetched and quietly hide the rest.
class MyOrdersPage extends GetView<OrdersController> {
  const MyOrdersPage({super.key});

  static const double _gutter = 20.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Home forces light status-bar glyphs for its dark hero; this screen has
      // no artwork behind the bar, so it restores the theme's own contrast.
      value: palette.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarBrightness: Brightness.light,
            ),
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OrdersHeader(),
              Expanded(
                child: Obx(() {
                  final state = controller.stateFor<List<OrderEntity>>(kOrders);
                  return state.value.when(
                    onInitial: () => const _OrdersLoading(),
                    onLoading: () => const _OrdersLoading(),
                    onSuccess: (orders, _) => _OrdersList(orders: orders),
                    onError: (message, _) => _OrdersError(message: message),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back control, serif title, and a one-line count of what is in the list.
class _OrdersHeader extends GetView<OrdersController> {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MyOrdersPage._gutter,
        4,
        MyOrdersPage._gutter,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                GestureDetector(
                  onTap: Get.back,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.hairline),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 22,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            LocaleKeys.myOrders.tr,
            style: MarketplaceTypography.heroDisplay.copyWith(
              fontSize: 34,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final orders = controller.orders;
            if (orders.isEmpty) return const SizedBox.shrink();

            final onTheWay = orders
                .where((order) =>
                    order.status == OrderStatus.shipped ||
                    order.status == OrderStatus.processing ||
                    order.status == OrderStatus.readyForPickup)
                .length;

            final parts = <String>[
              LocaleKeys.ordersCount.trParams({'count': '${orders.length}'}),
              if (onTheWay > 0)
                LocaleKeys.ordersOnTheWay.trParams({'count': '$onTheWay'}),
            ];

            return Text(
              parts.join(' · '),
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11.5,
                color: palette.textSecondary,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OrdersLoading extends StatelessWidget {
  const _OrdersLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.palette.brand),
    );
  }
}

class _OrdersList extends GetView<OrdersController> {
  const _OrdersList({required this.orders});

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshOrders,
        color: palette.brand,
        backgroundColor: palette.surface,
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
              MyOrdersPage._gutter,
              4,
              MyOrdersPage._gutter,
              MarketplaceSpacing.xxl + 40,
            ),
            itemCount: orders.length + (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              if (index >= orders.length) {
                return Padding(
                  padding: const EdgeInsets.all(MarketplaceSpacing.md),
                  child: Center(
                    child: SizedBox(
                      width: MarketplaceSpacing.lg,
                      height: MarketplaceSpacing.lg,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.brand,
                      ),
                    ),
                  ),
                );
              }

              final order = orders[index];
              void openDetails() => Get.toNamed(
                    Routes.MARKETPLACE_ORDER_DETAILS,
                    arguments: order.id,
                  );

              return OrderListItem(
                order: order,
                onTap: openDetails,
                // The inline action names what this order actually affords —
                // refund and cancel are status-gated by the API, everything
                // else just opens the detail.
                actionLabel: _actionLabelFor(order),
                onAction: _actionLabelFor(order) == null
                    ? null
                    : order.canRequestRefund
                        ? () => Get.toNamed(
                              Routes.MARKETPLACE_REFUND_REQUEST,
                              arguments: order,
                            )
                        : openDetails,
              );
            },
          ),
        ),
      ),
    );
  }

  static String? _actionLabelFor(OrderEntity order) {
    if (order.canRequestRefund) return LocaleKeys.requestRefund.tr;
    if (order.canCancel) return LocaleKeys.cancelOrder.tr;
    if (order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.refunded) {
      return null;
    }
    return LocaleKeys.viewDetails.tr;
  }
}

class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color:
                  palette.accent.withValues(alpha: palette.isDark ? 0.14 : 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: palette.brand,
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.lg),
          Text(
            LocaleKeys.noOrders.tr,
            style: MarketplaceTypography.sectionDisplay.copyWith(
              color: palette.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          Text(
            LocaleKeys.noOrdersDesc.tr,
            style: MarketplaceTypography.descriptionBody.copyWith(
              color: palette.textSecondary,
            ),
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
              onPressed: controller.refreshOrders,
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
