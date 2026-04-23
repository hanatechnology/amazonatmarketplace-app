import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../localization/locale_keys.dart';
import 'checkout_order_item_row.dart';
import 'checkout_section_header.dart';

class CheckoutOrderSummaryDto {
  const CheckoutOrderSummaryDto({
    required this.items,
    required this.subtotal,
    this.isExpanded = false,
    required this.onToggle,
  });

  final List<CheckoutOrderItemDto> items;
  final double subtotal;
  final bool isExpanded;
  final VoidCallback onToggle;
}

/// Collapsible order summary card. Tap header to expand/collapse the item list.
class CheckoutOrderSummary extends StatelessWidget {
  const CheckoutOrderSummary({super.key, required this.data});

  final CheckoutOrderSummaryDto data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MarketplaceColors.surface,
        borderRadius: BorderRadius.circular(MarketplaceRadius.card),
        border: Border.all(color: MarketplaceColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Collapsed header ──────────────────────────────────
          InkWell(
            onTap: data.onToggle,
            borderRadius: BorderRadius.circular(MarketplaceRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(MarketplaceSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: CheckoutSectionHeader(
                      data: CheckoutSectionHeaderDto(
                        title: LocaleKeys.orderSummary.tr,
                      ),
                    ),
                  ),
                  const SizedBox(width: MarketplaceSpacing.sm),
                  Text(
                    LocaleKeys.items.trParams({'count': data.items.length.toString()}),
                    style: MarketplaceTypography.bodySecondary,
                  ),
                  const SizedBox(width: MarketplaceSpacing.sm),
                  Icon(
                    data.isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: MarketplaceColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // ── Expandable items list ─────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: data.isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                Divider(
                  height: 1,
                  color: MarketplaceColors.stroke.withValues(alpha: 0.6),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MarketplaceSpacing.md,
                    MarketplaceSpacing.sm,
                    MarketplaceSpacing.md,
                    MarketplaceSpacing.md,
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < data.items.length; i++) ...[
                        if (i > 0)
                          const SizedBox(height: MarketplaceSpacing.sm),
                        CheckoutOrderItemRow(data: data.items[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
