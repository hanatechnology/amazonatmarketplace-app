import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/components/marketplace/notifications/relative_time.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_palette.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';
import 'package:marketplace/domain/entities/marketplace/notification_entity.dart';

class NotificationTileDto {
  const NotificationTileDto({
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
    this.isMarkingRead = false,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final bool isMarkingRead;
}

/// One notification row.
///
/// Unread rows carry a tinted surface and an accent bar on the leading edge —
/// two signals, because the tint alone is nearly invisible in dark mode.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.dto});

  final NotificationTileDto dto;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final notification = dto.notification;
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: dto.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isUnread
              ? Color.alphaBlend(
                  palette.accent
                      .withValues(alpha: palette.isDark ? 0.07 : 0.30),
                  palette.surface,
                )
              : palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.hairline),
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent rail — full-height, leading edge, unread only.
              SizedBox(
                width: 3,
                child: ColoredBox(
                  color: isUnread ? palette.brand : Colors.transparent,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TypeIcon(notification: notification),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style:
                                        MarketplaceTypography.rowTitle.copyWith(
                                      fontSize: 13,
                                      color: palette.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _TimeStamp(
                                  sentAt: notification.sentAt,
                                  isUnread: isUnread,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              style: MarketplaceTypography.rowMeta.copyWith(
                                fontSize: 11.5,
                                color: palette.textSecondary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (notification.isRoutable) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    _actionLabel(notification).toUpperCase(),
                                    style:
                                        MarketplaceTypography.linkCaps.copyWith(
                                      color: palette.brand,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 14,
                                    color: palette.brand,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A refund notification carries a refund id, not an order id, so it lands on
  /// the order list rather than one order — the label says so.
  static String _actionLabel(NotificationEntity notification) =>
      switch (notification.referenceType) {
        NotificationReferenceType.order => LocaleKeys.viewOrder.tr,
        NotificationReferenceType.refund => LocaleKeys.myOrders.tr,
        _ => LocaleKeys.viewDetails.tr,
      };
}

/// Rounded icon tile, coloured by what the notification is about.
class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.notification});

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, tint) = _iconFor(notification, palette);

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: palette.isDark ? 0.20 : 0.14),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 17, color: tint),
    );
  }

  static (IconData, Color) _iconFor(
    NotificationEntity notification,
    MarketplacePalette palette,
  ) {
    if (notification.referenceType == NotificationReferenceType.refund) {
      return (Icons.replay_rounded, const Color(0xFFE8963C));
    }
    return switch (notification.type) {
      NotificationType.orderStatus => (
          Icons.local_shipping_outlined,
          palette.isDark ? const Color(0xFF8FBEFF) : const Color(0xFF2F72C9),
        ),
      NotificationType.announcement => (
          Icons.campaign_outlined,
          palette.brand,
        ),
      NotificationType.system || NotificationType.unknown => (
          Icons.info_outline_rounded,
          palette.textSecondary,
        ),
    };
  }
}

class _TimeStamp extends StatelessWidget {
  const _TimeStamp({required this.sentAt, required this.isUnread});

  final DateTime sentAt;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isUnread) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: palette.brand,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
        ],
        Text(
          formatRelativeTime(sentAt),
          style: MarketplaceTypography.rowMeta.copyWith(
            fontSize: 9.5,
            color: palette.textMuted,
          ),
        ),
      ],
    );
  }
}
