import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/components/marketplace/notifications/relative_time.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
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

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.dto});

  final NotificationTileDto dto;

  @override
  Widget build(BuildContext context) {
    final notification = dto.notification;
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread
          ? MarketplaceColors.secondary.withValues(alpha: 0.25)
          : MarketplaceColors.surface,
      child: InkWell(
        onTap: dto.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.md,
            vertical: MarketplaceSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread dot — keeps its width when read so rows stay aligned.
              Container(
                width: MarketplaceSpacing.sm,
                height: MarketplaceSpacing.sm,
                margin: const EdgeInsetsDirectional.only(
                  top: MarketplaceSpacing.xs,
                  end: MarketplaceSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isUnread
                      ? MarketplaceColors.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isUnread
                                ? MarketplaceTypography.bodyBold
                                : MarketplaceTypography.body,
                          ),
                        ),
                        const SizedBox(width: MarketplaceSpacing.sm),
                        Text(
                          formatRelativeTime(notification.sentAt),
                          style: MarketplaceTypography.micro.copyWith(
                            color: MarketplaceColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: MarketplaceSpacing.xxs),
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: MarketplaceTypography.descriptionBody,
                      ),
                    ],
                    if (isUnread) ...[
                      const SizedBox(height: MarketplaceSpacing.xs),
                      InkWell(
                        onTap: dto.isMarkingRead ? null : dto.onMarkRead,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: MarketplaceSpacing.xxs,
                          ),
                          child: Text(
                            LocaleKeys.markRead.tr,
                            style: MarketplaceTypography.micro.copyWith(
                              color: dto.isMarkingRead
                                  ? MarketplaceColors.textMuted
                                  : MarketplaceColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
