import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/price_formatter.dart';

class CheckoutBottomBarDto {
  const CheckoutBottomBarDto({
    required this.subtotal,
    required this.total,
    required this.isLoading,
    required this.isEnabled,
    required this.onPlaceOrder,
    this.shippingFee,
    this.isShippingLoading = false,
  });

  final double subtotal;

  /// Subtotal plus delivery once the preview lands.
  final double total;

  /// From `GET /orders/shipping-fee`. Null means not previewed yet — the row
  /// reads as pending rather than claiming a free delivery.
  final double? shippingFee;
  final bool isShippingLoading;

  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPlaceOrder;
}

/// Sticky summary and the one action on the screen.
///
/// The figures live here rather than in the scroll body: shipping is the last
/// unknown, and it resolves while the customer is still choosing, so the total
/// has to stay in view as it changes.
class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({super.key, required this.data});

  final CheckoutBottomBarDto data;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final canSubmit = data.isEnabled && !data.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SummaryRow(
                label: LocaleKeys.subtotal.tr,
                child: _Money(amount: data.subtotal),
              ),
              const SizedBox(height: 6),
              _SummaryRow(
                label: LocaleKeys.shippingFee.tr,
                child: data.shippingFee == null || data.isShippingLoading
                    ? Text(
                        LocaleKeys.shippingPending.tr,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 10.5,
                          color: palette.textMuted,
                        ),
                      )
                    : _Money(amount: data.shippingFee!),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: palette.hairline)),
                ),
                child: _SummaryRow(
                  label: LocaleKeys.totalCost.tr,
                  isTotal: true,
                  child: _Money(amount: data.total, isTotal: true),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: canSubmit ? data.onPlaceOrder : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.brand,
                    foregroundColor: palette.onBrand,
                    disabledBackgroundColor: palette.surfaceSunken,
                    disabledForegroundColor: palette.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketplaceRadius.full),
                    ),
                  ),
                  child: data.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.onBrand,
                          ),
                        )
                      : Text(
                          LocaleKeys.placeOrder.tr,
                          style:
                              MarketplaceTypography.buttonLabel.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: canSubmit
                                ? palette.onBrand
                                : palette.textMuted,
                          ),
                        ),
                ),
              ),
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
    required this.child,
    this.isTotal = false,
  });

  final String label;
  final Widget child;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      crossAxisAlignment:
          isTotal ? CrossAxisAlignment.center : CrossAxisAlignment.baseline,
      textBaseline: isTotal ? null : TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            label,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontSize: isTotal ? 13 : 12,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isTotal ? palette.textPrimary : palette.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        child,
      ],
    );
  }
}

/// Figure then unit, Latin digits, left-to-right in both languages.
class _Money extends StatelessWidget {
  const _Money({required this.amount, this.isTotal = false});

  final double amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      textDirection: TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          PriceFormatter.amount(amount),
          style: isTotal
              ? MarketplaceTypography.priceDisplay.copyWith(
                  fontSize: 25,
                  color: palette.textPrimary,
                )
              : MarketplaceTypography.rowTitle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
        ),
        const SizedBox(width: 4),
        Text(
          PriceFormatter.unit(),
          style: MarketplaceTypography.priceUnit.copyWith(
            fontSize: isTotal ? 10 : 9,
            color: palette.textMuted,
          ),
        ),
      ],
    );
  }
}
