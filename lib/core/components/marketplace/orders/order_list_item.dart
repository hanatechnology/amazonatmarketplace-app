import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/date_formatter.dart';
import '../../../utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import 'order_status_badge.dart';

/// One row in the order history list.
class OrderListItem extends StatelessWidget {
  const OrderListItem({super.key, required this.order, required this.onTap});

  final OrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MarketplaceRadius.card),
      child: Container(
        padding: const EdgeInsets.all(MarketplaceSpacing.md),
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.card),
          border: Border.all(color: MarketplaceColors.strokeLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${LocaleKeys.orderNumber.tr}${order.orderNumber}',
                          style: MarketplaceTypography.cardTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: MarketplaceSpacing.sm),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: MarketplaceSpacing.xs),
                  if (order.vendorName.isNotEmpty)
                    Text(
                      order.vendorName,
                      style: MarketplaceTypography.cardSubtitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    DateFormatter.mediumDate(order.createdAt),
                    style: MarketplaceTypography.micro.copyWith(
                      color: MarketplaceColors.textMuted,
                    ),
                  ),
                  Text(
                    '${order.itemCount} ${LocaleKeys.items.tr}',
                    style: MarketplaceTypography.micro.copyWith(
                      color: MarketplaceColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MarketplaceSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  PriceFormatter.format(order.totalAmount),
                  style: MarketplaceTypography.cardPrice.copyWith(
                    color: MarketplaceColors.primary,
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.xs),
                Text(
                  LocaleKeys.viewDetails.tr,
                  style: MarketplaceTypography.micro.copyWith(
                    color: MarketplaceColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
