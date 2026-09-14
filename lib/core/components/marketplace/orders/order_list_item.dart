import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/date_formatter.dart';
import '../../../utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';
import '../app_network_image.dart';
import '../refunds/refund_status_badge.dart';
import 'order_status_badge.dart';

/// One order in the history list.
///
/// Reads top to bottom as: what it is (number + status), what is in it
/// (thumbnails, store, item count), what it cost (date + total).
class OrderListItem extends StatelessWidget {
  const OrderListItem({
    super.key,
    required this.order,
    required this.onTap,
    this.onAction,
    this.actionLabel,
  });

  final OrderEntity order;
  final VoidCallback onTap;

  /// Inline action under the card — cancel, refund, or open. Hidden when null.
  final VoidCallback? onAction;
  final String? actionLabel;

  /// Thumbnails shown before the "+N" overflow chip.
  static const int _maxThumbs = 3;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isClosed = order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.refunded;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isClosed ? 0.72 : 1,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${LocaleKeys.orderNumber.tr}${order.orderNumber}',
                      // "#AMZ-2608-08176" is a Latin token: without this the
                      // hash jumps to the wrong end in Arabic.
                      textDirection: TextDirection.ltr,
                      style: MarketplaceTypography.cardHeading.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OrderStatusBadge(status: order.status),
                ],
              ),

              // A delivered order with a refund against it is not just
              // "delivered". The lifecycle badge above still tells the truth
              // about the ORDER, so the refund gets its own chip rather than
              // replacing it — "Rejected" sitting alone where the status
              // usually goes would read as the order being rejected.
              if (order.headlineRefund != null) ...[
                const SizedBox(height: 9),
                _RefundChip(refund: order.headlineRefund!),
              ],

              const SizedBox(height: 12),
              Row(
                children: [
                  _Thumbnails(items: order.items),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (order.vendorName.isNotEmpty)
                          Text(
                            order.vendorName,
                            style: MarketplaceTypography.rowTitle.copyWith(
                              color: palette.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 3),
                        Text(
                          LocaleKeys.itemsCountOne.trPluralParams(
                            LocaleKeys.itemsCount,
                            order.itemCount,
                            {'count': '${order.itemCount}'},
                          ),
                          style: MarketplaceTypography.rowMeta.copyWith(
                            color: palette.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: palette.hairline)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormatter.mediumDate(order.createdAt),
                        style: MarketplaceTypography.rowMeta.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                    Text.rich(
                      textDirection: TextDirection.ltr,
                      TextSpan(
                        text: PriceFormatter.amount(order.totalAmount),
                        style: MarketplaceTypography.priceDisplay.copyWith(
                          fontSize: 20,
                          color: palette.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: ' ${PriceFormatter.unit()}',
                            style: MarketplaceTypography.priceUnit.copyWith(
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onAction,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        actionLabel!.toUpperCase(),
                        style: MarketplaceTypography.linkCaps.copyWith(
                          color: palette.brand,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 15,
                        color: palette.brand,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlapping product thumbnails, capped with a "+N" chip.
class _Thumbnails extends StatelessWidget {
  const _Thumbnails({required this.items});

  final List<OrderItemEntity> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (items.isEmpty) return const SizedBox.shrink();

    final shown = items.take(OrderListItem._maxThumbs).toList();
    final overflow = items.length - shown.length;

    Widget frame(Widget child) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: palette.surfaceSunken,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.surface, width: 2),
        ),
        clipBehavior: Clip.hardEdge,
        child: child,
      );
    }

    // Overlap is laid out in a Stack, not with a negative margin: Container
    // asserts its margin is non-negative and throws in release as well as debug.
    final tiles = <Widget>[
      for (final item in shown)
        frame(
          AppNetworkImage(
            imageUrl: item.imageUrl ?? '',
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
      if (overflow > 0)
        frame(
          Center(
            child: Text(
              '+$overflow',
              style: MarketplaceTypography.rowMeta.copyWith(
                color: palette.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
    ];

    const step = 32.0;

    return SizedBox(
      width: 44 + (tiles.length - 1) * step,
      height: 44,
      child: Stack(
        children: [
          for (var i = 0; i < tiles.length; i++)
            PositionedDirectional(start: i * step, child: tiles[i]),
        ],
      ),
    );
  }
}


/// "Refund · Under review" — the refund's own state, called out on the card.
class _RefundChip extends StatelessWidget {
  const _RefundChip({required this.refund});

  final RefundEntity refund;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = RefundStatusBadge.toneFor(refund.status);
    final isDark = palette.isDark;
    final foreground = tone.foreground(isDark);

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 5, 11, 5),
      decoration: BoxDecoration(
        color: tone.background(isDark),
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A returning-arrow depicts a return; it is not a direction the
          // reader follows, so it does not flip with the script.
          Icon(Icons.assignment_return_outlined, size: 13, color: foreground),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '${LocaleKeys.refundLabel.tr} · '
              '${RefundStatusBadge.labelFor(refund.status)}',
              style: MarketplaceTypography.rowMeta.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
