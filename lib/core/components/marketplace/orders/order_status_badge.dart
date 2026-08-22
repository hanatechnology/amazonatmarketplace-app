import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';

/// Pill showing an order's lifecycle status. Colour grouping mirrors the web
/// client's badge variants.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.sm,
        vertical: MarketplaceSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(MarketplaceRadius.badge),
      ),
      child: Text(
        _labelFor(status),
        style: MarketplaceTypography.micro.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _labelFor(OrderStatus status) => switch (status) {
        OrderStatus.pending => LocaleKeys.statusPending.tr,
        OrderStatus.paid => LocaleKeys.statusPaid.tr,
        OrderStatus.cod => LocaleKeys.statusCod.tr,
        OrderStatus.processing => LocaleKeys.statusProcessing.tr,
        OrderStatus.shipped => LocaleKeys.statusShipped.tr,
        OrderStatus.readyForPickup => LocaleKeys.statusReadyForPickup.tr,
        OrderStatus.delivered => LocaleKeys.statusDelivered.tr,
        OrderStatus.cancelled => LocaleKeys.statusCancelled.tr,
        OrderStatus.refunded => LocaleKeys.statusRefunded.tr,
        OrderStatus.unknown => LocaleKeys.statusUnknown.tr,
      };

  static _BadgePalette _paletteFor(OrderStatus status) => switch (status) {
        OrderStatus.pending => const _BadgePalette(
            background: MarketplaceColors.warningSurface,
            foreground: MarketplaceColors.warningContent,
          ),
        OrderStatus.paid ||
        OrderStatus.cod ||
        OrderStatus.processing =>
          const _BadgePalette(
            background: MarketplaceColors.infoSurface,
            foreground: MarketplaceColors.infoContent,
          ),
        OrderStatus.shipped || OrderStatus.readyForPickup => const _BadgePalette(
            background: MarketplaceColors.secondary,
            foreground: MarketplaceColors.primary,
          ),
        OrderStatus.delivered => const _BadgePalette(
            background: MarketplaceColors.successSurface,
            foreground: MarketplaceColors.successContent,
          ),
        OrderStatus.cancelled => const _BadgePalette(
            background: MarketplaceColors.errorSurface,
            foreground: MarketplaceColors.errorContent,
          ),
        OrderStatus.refunded || OrderStatus.unknown => const _BadgePalette(
            background: MarketplaceColors.neutralSurface,
            foreground: MarketplaceColors.neutralContent,
          ),
      };
}

class _BadgePalette {
  const _BadgePalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
