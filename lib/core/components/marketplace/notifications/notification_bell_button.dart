import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';
import 'package:marketplace/presentation/controllers/marketplace/notification_badge_controller.dart';
import 'package:marketplace/app/routes/app_router.dart';

/// Header bell with an unread badge. Refreshes the count on return so the badge
/// reflects anything read while the notifications screen was open.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationBadgeController>();

    return InkWell(
      onTap: () async {
        await AppRouter.toNamed(Routes.MARKETPLACE_NOTIFICATIONS);
        await controller.loadUnreadCount();
      },
      borderRadius: BorderRadius.circular(MarketplaceRadius.md),
      child: Container(
        width: MarketplaceSpacing.filterButtonSize,
        height: MarketplaceSpacing.filterButtonSize,
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.md),
          border: Border.all(color: MarketplaceColors.stroke),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: MarketplaceColors.iconInactive,
            ),
            Obx(() {
              final count = controller.unreadCount;
              if (count <= 0) return const SizedBox.shrink();
              return PositionedDirectional(
                top: MarketplaceSpacing.sm,
                end: MarketplaceSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MarketplaceSpacing.xs,
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: MarketplaceColors.statusClosed,
                    borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: MarketplaceTypography.micro.copyWith(
                      color: MarketplaceColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
