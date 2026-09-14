import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';

/// Four-step lifecycle rail: placed → paid → shipped → delivered.
///
/// Steps carry no dates. The API returns the current status and `created_at`
/// only — there is no per-transition timestamp and no tracking endpoint, so a
/// dated timeline would be invented data.
///
/// Cancelled and refunded orders have left the happy path; [stepFor] returns
/// null for them and the caller shows the reason strip instead.
class OrderProgressRail extends StatelessWidget {
  const OrderProgressRail({super.key, required this.status});

  final OrderStatus status;

  /// Index of the step the order is currently on, or null when the rail does
  /// not apply.
  static int? stepFor(OrderStatus status) => switch (status) {
        OrderStatus.pending => 0,
        OrderStatus.paid || OrderStatus.cod || OrderStatus.processing => 1,
        OrderStatus.shipped || OrderStatus.readyForPickup => 2,
        OrderStatus.delivered => 3,
        OrderStatus.cancelled ||
        OrderStatus.refunded ||
        OrderStatus.unknown =>
          null,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final current = stepFor(status);
    if (current == null) return const SizedBox.shrink();

    final labels = [
      LocaleKeys.stepPlaced.tr,
      LocaleKeys.stepPaid.tr,
      LocaleKeys.stepShipped.tr,
      LocaleKeys.stepDelivered.tr,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: _Step(
              label: labels[i],
              isReached: i <= current,
              isCurrent: i == current,
              // Each cell paints half a connector on each side; adjacent halves
              // meet to form one continuous line between dots.
              leadingReached: i > 0 ? i <= current : null,
              trailingReached: i < labels.length - 1 ? i + 1 <= current : null,
              palette: palette,
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.isReached,
    required this.isCurrent,
    required this.leadingReached,
    required this.trailingReached,
    required this.palette,
  });

  final String label;
  final bool isReached;
  final bool isCurrent;

  /// Null when this side has no connector (first / last step).
  final bool? leadingReached;
  final bool? trailingReached;

  final MarketplacePalette palette;

  @override
  Widget build(BuildContext context) {
    Widget half(bool? reached) {
      if (reached == null) return const Expanded(child: SizedBox.shrink());
      return Expanded(
        child: Container(
          height: 2,
          color: reached ? palette.brand : palette.hairline,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              half(leadingReached),
              // The halo is an outer circle rather than a border: a border
              // would eat into the 12px dot instead of growing around it.
              Container(
                width: isCurrent ? 20 : 12,
                height: isCurrent ? 20 : 12,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? palette.brand.withValues(alpha: 0.24)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isReached ? palette.brand : palette.hairline,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              half(trailingReached),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: MarketplaceTypography.rowMeta.copyWith(
            fontWeight: FontWeight.w600,
            color: isReached ? palette.textPrimary : palette.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
