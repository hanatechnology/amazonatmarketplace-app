import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../domain/entities/marketplace/checkout_args.dart';

class OrderConfirmedPage extends StatelessWidget {
  const OrderConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as OrderConfirmedArgs?;

    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MarketplaceSpacing.screenPaddingH,
          ),
          child: Column(
            children: [
              const Spacer(),

              // ── Success icon ─────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: MarketplaceColors.secondary.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: MarketplaceColors.primary,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.lg),

              // ── Title & subtitle ─────────────────────────────
              Text(
                LocaleKeys.orderConfirmed.tr,
                style: MarketplaceTypography.screenTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Text(
                args?.orderId != null
                    ? '${LocaleKeys.orderOnItsWay.tr} #${args!.orderId}'
                    : LocaleKeys.orderOnItsWay.tr,
                style: MarketplaceTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MarketplaceSpacing.xl),

              // ── Order summary card ───────────────────────────
              if (args != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(MarketplaceSpacing.md),
                  decoration: BoxDecoration(
                    color: MarketplaceColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(MarketplaceRadius.card),
                    border: Border.all(color: MarketplaceColors.secondary),
                  ),
                  child: Column(
                    children: [
                      if (args.orderId != null)
                        _SummaryRow(
                          label: 'Order ID',
                          value: '#${args.orderId}',
                        ),
                      _SummaryRow(
                        label: 'Payment',
                        value: args.paymentMethod,
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: '\$${args.total.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // ── CTAs ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: MarketplaceSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.MARKETPLACE_ORDERS),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarketplaceColors.primary,
                    foregroundColor: MarketplaceColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketplaceRadius.button),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.trackMyOrder.tr,
                    style: MarketplaceTypography.buttonLabel,
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              SizedBox(
                width: double.infinity,
                height: MarketplaceSpacing.buttonHeight,
                child: OutlinedButton(
                  onPressed: () =>
                      Get.offAllNamed(Routes.MARKETPLACE_MAIN),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MarketplaceColors.primary,
                    side: const BorderSide(color: MarketplaceColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketplaceRadius.button),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.continueShopping.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      color: MarketplaceColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? MarketplaceTypography.sectionSubheading
        : MarketplaceTypography.bodySecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MarketplaceSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: MarketplaceTypography.bodySecondary),
          Text(value, style: style),
        ],
      ),
    );
  }
}
