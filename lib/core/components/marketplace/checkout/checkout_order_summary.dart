import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/checkout_args.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/price_formatter.dart';
import '../app_network_image.dart';
import 'checkout_section_label.dart';

/// What the customer is paying for, collapsed by default.
///
/// Checkout's bottom bar carries the totals but never the lines behind them, so
/// there was no way to check what was in the order without going back to the
/// cart. The header stays tappable at both states — collapsing is how you get
/// the address and payment steps back on screen on a short device.
class CheckoutOrderSummary extends StatelessWidget {
  const CheckoutOrderSummary({
    super.key,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
  });

  final List<CheckoutItemRecord> items;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionLabel(title: LocaleKeys.orderSummary.tr),
        const SizedBox(height: MarketplaceSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(MarketplaceRadius.md + 2),
            border: Border.all(color: palette.hairline),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(MarketplaceRadius.md + 2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MarketplaceSpacing.md - 4,
                    vertical: MarketplaceSpacing.sm + 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.itemsCountOne.trPluralParams(
                            LocaleKeys.itemsCount,
                            items.length,
                            {'count': '${items.length}'},
                          ),
                          style: MarketplaceTypography.rowTitle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        isExpanded
                            ? LocaleKeys.hideItems.tr
                            : LocaleKeys.showItems.tr,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          color: palette.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: MarketplaceSpacing.xs),
                      // Chevron, not a directional arrow: it points at the
                      // sheet's own motion, which is vertical in both scripts.
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: isExpanded
                    ? Column(
                        children: [
                          for (final item in items)
                            _SummaryLine(item: item, palette: palette),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.item, required this.palette});

  final CheckoutItemRecord item;
  final MarketplacePalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MarketplaceSpacing.md - 4,
        0,
        MarketplaceSpacing.md - 4,
        MarketplaceSpacing.sm + 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
            child: AppNetworkImage(
              imageUrl: item.imageUrl,
              width: 42,
              height: 42,
              borderRadius: MarketplaceRadius.sm,
            ),
          ),
          const SizedBox(width: MarketplaceSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: MarketplaceTypography.rowTitle.copyWith(
                    color: palette.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: MarketplaceSpacing.xxs),
                // Quantity is a figure: Latin digits, left to right, in Arabic
                // as much as in English.
                Text(
                  '×${item.quantity}',
                  textDirection: TextDirection.ltr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: MarketplaceSpacing.sm),
          Text(
            PriceFormatter.format(item.productPrice * item.quantity),
            textDirection: TextDirection.ltr,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
