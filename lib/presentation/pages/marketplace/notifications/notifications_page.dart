import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/notifications/notification_filter_chips.dart';
import '../../../../core/components/marketplace/notifications/notification_tile.dart';
import '../../../../core/components/marketplace/notifications/notification_tile_shimmer.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/notification_entity.dart';
import '../../../controllers/marketplace/notifications_controller.dart';

/// Notification centre: read-state filter, day-grouped list, infinite scroll.
class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  static const double _gutter = 20.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
              const _NotificationsHeader(),
              Expanded(
                child: Obx(() {
                  final state = controller.stateFor<List<NotificationEntity>>(
                    NotificationsController.kNotifications,
                  );
                  return state.value.when(
                    onInitial: () => const _NotificationsLoading(),
                    onLoading: () => const _NotificationsLoading(),
                    onSuccess: (notifications, _) =>
                        _NotificationsList(notifications: notifications),
                    onError: (message, _) =>
                        _NotificationsError(message: message),
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

/// Back control, "mark all as read", serif title with the unread count, and the
/// read-state chips.
class _NotificationsHeader extends GetView<NotificationsController> {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NotificationsPage._gutter,
        4,
        NotificationsPage._gutter,
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
                const Spacer(),
                Obx(() {
                  // Nothing to mark, or a request already in flight.
                  if (controller.unreadCount <= 0) {
                    return const SizedBox.shrink();
                  }
                  final busy = controller.isMarkingAllRead;

                  return GestureDetector(
                    onTap: busy ? null : controller.markAllAsRead,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.full),
                        border: Border.all(color: palette.hairline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (busy)
                            SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: palette.brand,
                              ),
                            )
                          else
                            Icon(
                              Icons.done_all_rounded,
                              size: 15,
                              color: palette.brand,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            LocaleKeys.markAllRead.tr,
                            style: MarketplaceTypography.pillLabel.copyWith(
                              color: palette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  LocaleKeys.notifications.tr,
                  style: MarketplaceTypography.heroDisplay.copyWith(
                    fontSize: 32,
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Obx(() {
                if (controller.unreadCount <= 0) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  constraints: const BoxConstraints(minWidth: 24),
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.brand,
                    borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                  ),
                  child: Text(
                    '${controller.unreadCount}',
                    textDirection: TextDirection.ltr,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: palette.onBrand,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 6),
          Obx(() {
            final total = controller
                    .getOperationData<List<NotificationEntity>>(
                      NotificationsController.kNotifications,
                    )
                    ?.length ??
                0;
            if (total == 0) return const SizedBox.shrink();

            return Text(
              LocaleKeys.unreadOfTotal.trParams({
                'unread': '${controller.unreadCount}',
                'total': '$total',
              }),
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11.5,
                color: palette.textSecondary,
              ),
            );
          }),
          const SizedBox(height: 12),
          Obx(() => NotificationFilterChips(
                dto: NotificationFilterChipsDto(
                  current: controller.filter.value,
                  unreadCount: controller.unreadCount,
                  onChanged: controller.changeFilter,
                ),
              )),
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
      padding: const EdgeInsets.fromLTRB(
        NotificationsPage._gutter,
        4,
        NotificationsPage._gutter,
        MarketplaceSpacing.xxl,
      ),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const NotificationTileShimmer(),
    );
  }
}

/// The list, grouped into today / yesterday / earlier.
class _NotificationsList extends GetView<NotificationsController> {
  const _NotificationsList({required this.notifications});

  final List<NotificationEntity> notifications;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshNotifications,
        color: palette.brand,
        backgroundColor: palette.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: MarketplaceSpacing.xxl),
            _NotificationsEmpty(),
          ],
        ),
      );
    }

    final rows = _group(notifications);

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
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
              NotificationsPage._gutter,
              4,
              NotificationsPage._gutter,
              MarketplaceSpacing.xxl,
            ),
            itemCount: rows.length + (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, index) {
              // A heading needs air above it, rows sit tighter together.
              if (index + 1 < rows.length && rows[index + 1] is _HeadingRow) {
                return const SizedBox(height: 18);
              }
              return const SizedBox(height: 10);
            },
            itemBuilder: (_, index) {
              if (index >= rows.length) {
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

              final row = rows[index];
              if (row is _HeadingRow) {
                return Text(
                  row.label.toUpperCase(),
                  style: MarketplaceTypography.labelCaps.copyWith(
                    color: palette.textMuted,
                    letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.4,
                  ),
                );
              }

              final notification = (row as _NotificationRow).notification;
              return Obx(() => NotificationTile(
                    dto: NotificationTileDto(
                      notification: notification,
                      isMarkingRead: controller.isMarkingRead(notification.id),
                      onTap: () => controller.onNotificationTap(notification),
                      onMarkRead: () => controller.markAsRead(notification),
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }

  /// Flattens the list into headings + rows. Grouping is by calendar day in the
  /// device's timezone, which is what "today" means to the person reading it.
  static List<_Row> _group(List<NotificationEntity> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final rows = <_Row>[];
    String? currentLabel;

    for (final notification in notifications) {
      final sent = notification.sentAt.toLocal();
      final day = DateTime(sent.year, sent.month, sent.day);

      final label = day == today
          ? LocaleKeys.groupToday.tr
          : day == yesterday
              ? LocaleKeys.groupYesterday.tr
              : LocaleKeys.groupEarlier.tr;

      if (label != currentLabel) {
        rows.add(_HeadingRow(label));
        currentLabel = label;
      }
      rows.add(_NotificationRow(notification));
    }

    return rows;
  }
}

sealed class _Row {
  const _Row();
}

class _HeadingRow extends _Row {
  const _HeadingRow(this.label);

  final String label;
}

class _NotificationRow extends _Row {
  const _NotificationRow(this.notification);

  final NotificationEntity notification;
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

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
              Icons.notifications_none_rounded,
              size: 34,
              color: palette.textMuted,
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.lg),
          Text(
            LocaleKeys.noNotifications.tr,
            style: MarketplaceTypography.sectionDisplay.copyWith(
              color: palette.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.sm),
          Text(
            LocaleKeys.noNotificationsMessage.tr,
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

class _NotificationsError extends GetView<NotificationsController> {
  const _NotificationsError({required this.message});

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
              onPressed: controller.refreshNotifications,
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
