import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/components/marketplace/marketplace_app_bar.dart';
import 'package:marketplace/core/components/marketplace/notifications/notification_filter_chips.dart';
import 'package:marketplace/core/components/marketplace/notifications/notification_tile.dart';
import 'package:marketplace/core/components/marketplace/notifications/notification_tile_shimmer.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';
import 'package:marketplace/domain/entities/marketplace/notification_entity.dart';
import 'package:marketplace/presentation/controllers/marketplace/notifications_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(
        title: LocaleKeys.notifications.tr,
        actions: [
          Obx(() {
            if (controller.unreadCount <= 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.isMarkingAllRead
                  ? null
                  : controller.markAllAsRead,
              child: Text(
                LocaleKeys.markAllRead.tr,
                style: MarketplaceTypography.micro.copyWith(
                  color: controller.isMarkingAllRead
                      ? MarketplaceColors.textMuted
                      : MarketplaceColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: MarketplaceSpacing.sm),
          Obx(
            () => NotificationFilterChips(
              dto: NotificationFilterChipsDto(
                current: controller.filter.value,
                onChanged: controller.changeFilter,
              ),
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          Expanded(
            child: Obx(() {
              final state = controller.stateFor<List<NotificationEntity>>(
                NotificationsController.kNotifications,
              );
              return state.value.when(
                onInitial: () => const _NotificationsLoading(),
                onLoading: () => const _NotificationsLoading(),
                onSuccess: (items, _) => _NotificationsList(
                  items: items,
                  controller: controller,
                ),
                onError: (message, _) => _NotificationsError(
                  message: message,
                  onRetry: controller.refreshNotifications,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NotificationsLoading extends StatelessWidget {
  const _NotificationsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        color: MarketplaceColors.strokeLight,
      ),
      itemBuilder: (_, __) => const NotificationTileShimmer(),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.items, required this.controller});

  final List<NotificationEntity> items;
  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshNotifications,
        color: MarketplaceColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: MarketplaceSpacing.xxl),
            _NotificationsEmpty(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
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
            itemCount: items.length + (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: MarketplaceColors.strokeLight,
            ),
            itemBuilder: (_, index) {
              if (index >= items.length) {
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

              final notification = items[index];
              return NotificationTile(
                dto: NotificationTileDto(
                  notification: notification,
                  onTap: () => controller.onNotificationTap(notification),
                  onMarkRead: () => controller.markAsRead(notification),
                  isMarkingRead: controller.isMarkingRead(notification.id),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

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
              Icons.notifications_none_rounded,
              size: 56,
              color: MarketplaceColors.primary,
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.lg),
          Text(
            LocaleKeys.noNotifications.tr,
            style: MarketplaceTypography.sectionHeading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          Text(
            LocaleKeys.noNotificationsMessage.tr,
            style: MarketplaceTypography.descriptionBody,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

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
              onPressed: onRetry,
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
