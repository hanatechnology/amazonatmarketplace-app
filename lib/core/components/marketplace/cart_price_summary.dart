import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../localization/locale_keys.dart';
import '../../utils/price_formatter.dart';
import 'package:get/get.dart';

/// DTO that carries the three price values into the widget.
class CartPriceSummaryDto {
  const CartPriceSummaryDto({
    required this.subtotal,
    required this.discount,
    required this.total,
    this.shippingFee,
    this.isShippingLoading = false,
  });

  final double subtotal;

  /// Pass 0 to hide the discount row.
  final double discount;

  final double total;

  /// Delivery cost from `GET /orders/shipping-fee`. Null means it has not been
  /// previewed yet — the row is hidden rather than showing a made-up zero.
  final double? shippingFee;
  final bool isShippingLoading;
}

/// Price summary card shown at the bottom of CartPage.
/// Shows subtotal, optional discount row, divider, and bold total.
class CartPriceSummary extends StatelessWidget {
  const CartPriceSummary({
    super.key,
    required this.data,
  });

  final CartPriceSummaryDto data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.md,
      ),
      padding: const EdgeInsets.all(MarketplaceSpacing.md),
      decoration: BoxDecoration(
        color: MarketplaceColors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(MarketplaceRadius.card),
        border: Border.all(
          color: MarketplaceColors.secondary,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _PriceRow(
            label: LocaleKeys.subtotal.tr,
            value: PriceFormatter.format(data.subtotal),
          ),
          // Discount (hidden when zero)
          if (data.discount > 0) ...[
            const SizedBox(height: MarketplaceSpacing.xs),
            _PriceRow(
              label: LocaleKeys.discount.tr,
              value: '-${PriceFormatter.format(data.discount)}',
              valueColor: const Color(0xFFD32F2F),
            ),
          ],
          if (data.isShippingLoading || data.shippingFee != null) ...[
            const SizedBox(height: MarketplaceSpacing.xs),
            _PriceRow(
              label: LocaleKeys.shippingFee.tr,
              value: data.isShippingLoading
                  ? '…'
                  : PriceFormatter.format(data.shippingFee!),
            ),
          ],
          const SizedBox(height: MarketplaceSpacing.sm),
          Divider(color: MarketplaceColors.stroke.withOpacity(0.6), height: 1),
          const SizedBox(height: MarketplaceSpacing.sm),
          // Total
          _PriceRow(
            label: LocaleKeys.totalCost.tr,
            value: PriceFormatter.format(data.total),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

/// Private reusable row used inside [CartPriceSummary].
class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isBold
        ? MarketplaceTypography.sectionSubheading
        : MarketplaceTypography.bodySecondary;
    final valueStyle = isBold
        ? MarketplaceTypography.sectionSubheading
        : MarketplaceTypography.bodySecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(
          value,
          style: valueColor != null
              ? valueStyle.copyWith(color: valueColor)
              : valueStyle,
        ),
      ],
    );
  }
}
