import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';

/// Price summary widget showing subtotal, discount, and total.
class PriceSummary extends StatelessWidget {
  const PriceSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.onCheckout,
  });

  final double subtotal;
  final double discount;
  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MarketplaceColors.secondary,
      padding: const EdgeInsets.all(MarketplaceSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _buildPriceRow(
            label: 'Subtotal',
            value: 'Rp${subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: MarketplaceSpacing.md),
          // Discount
          _buildPriceRow(
            label: 'Discount',
            value: '-Rp${discount.toStringAsFixed(0)}',
            valueColor: MarketplaceColors.primary,
          ),
          const SizedBox(height: MarketplaceSpacing.md),
          // Divider
          Divider(
            color: MarketplaceColors.stroke.withOpacity(0.3),
            height: 1,
          ),
          const SizedBox(height: MarketplaceSpacing.md),
          // Total
          _buildPriceRow(
            label: 'Total',
            value: 'Rp${total.toStringAsFixed(0)}',
            isTotal: true,
          ),
          const SizedBox(height: MarketplaceSpacing.lg),
          // Checkout button
          SizedBox(
            width: double.infinity,
            height: MarketplaceSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: MarketplaceColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: MarketplaceRadius.buttonBR,
                ),
              ),
              child: Text(
                'Checkout',
                style: MarketplaceTypography.buttonLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? MarketplaceTypography.sectionSubheading
              : MarketplaceTypography.bodySecondary,
        ),
        Text(
          value,
          style: (isTotal
                  ? MarketplaceTypography.sectionSubheading
                  : MarketplaceTypography.bodySecondary)
              .copyWith(color: valueColor),
        ),
      ],
    );
  }
}
