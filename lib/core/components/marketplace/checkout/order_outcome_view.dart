import 'package:flutter/material.dart';

import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/status_tone.dart';
import '../../../utils/price_formatter.dart';

/// One layout, two endings.
///
/// A placed order and a failed payment differ only in the seal colour and the
/// words; the receipt block, the actions and the spacing are identical, so
/// they share a widget rather than drifting apart in two files.
class OrderOutcomeView extends StatelessWidget {
  const OrderOutcomeView({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.lead,
    required this.statusLabel,
    required this.statusValue,
    required this.amountLabel,
    required this.primaryLabel,
    required this.onPrimary,
    required this.ghostLabel,
    required this.onGhost,
    this.orderNumber,
    this.orderNumberLabel,
    this.amount,
  });

  final bool isSuccess;
  final String title;
  final String lead;

  /// "Payment method" / "Status" — the middle receipt row.
  final String statusLabel;
  final String statusValue;

  final String amountLabel;

  /// Null hides the amount row: a payment that never went through has no
  /// figure worth stating as if it had.
  final double? amount;

  /// Null hides the order row — the checkout response does not always carry a
  /// customer-facing number, and a UUID is not one.
  final String? orderNumber;
  final String? orderNumberLabel;

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String ghostLabel;
  final VoidCallback onGhost;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = isSuccess ? StatusTone.success : StatusTone.danger;
    final isDark = palette.isDark;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 12),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tone.background(isDark),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Icon(
                        isSuccess
                            ? Icons.check_rounded
                            : Icons.priority_high_rounded,
                        size: 44,
                        color: tone.foreground(isDark),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: MarketplaceTypography.heroDisplay.copyWith(
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        lead,
                        textAlign: TextAlign.center,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 12.5,
                          height: 1.7,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _Receipt(
                      orderNumber: orderNumber,
                      orderNumberLabel: orderNumberLabel,
                      statusLabel: statusLabel,
                      statusValue: statusValue,
                      amountLabel: amountLabel,
                      amount: amount,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onPrimary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.brand,
                        foregroundColor: palette.onBrand,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MarketplaceRadius.full),
                        ),
                      ),
                      child: Text(
                        primaryLabel,
                        style: MarketplaceTypography.buttonLabel.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.onBrand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onGhost,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.textSecondary,
                        side: BorderSide(color: palette.hairline),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MarketplaceRadius.full),
                        ),
                      ),
                      child: Text(
                        ghostLabel,
                        style: MarketplaceTypography.buttonLabel.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Receipt extends StatelessWidget {
  const _Receipt({
    required this.statusLabel,
    required this.statusValue,
    required this.amountLabel,
    this.orderNumber,
    this.orderNumberLabel,
    this.amount,
  });

  final String statusLabel;
  final String statusValue;
  final String amountLabel;
  final String? orderNumber;
  final String? orderNumberLabel;
  final double? amount;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final rows = <Widget>[
      if (orderNumber != null && orderNumber!.isNotEmpty)
        _ReceiptRow(
          label: orderNumberLabel ?? '',
          child: Text(
            orderNumber!,
            textDirection: TextDirection.ltr,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ),
      _ReceiptRow(
        label: statusLabel,
        child: Text(
          statusValue,
          style: MarketplaceTypography.rowTitle.copyWith(
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
      ),
      if (amount != null)
        _ReceiptRow(
          label: amountLabel,
          child: _Money(amount: amount!),
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++)
            if (i == 0)
              rows[i]
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: palette.hairline)),
                ),
                child: rows[i],
              ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          child,
        ],
      ),
    );
  }
}

class _Money extends StatelessWidget {
  const _Money({required this.amount});

  final double amount;

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
          style: MarketplaceTypography.priceDisplay.copyWith(
            fontSize: 21,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          PriceFormatter.unit(),
          style: MarketplaceTypography.priceUnit.copyWith(
            fontSize: 9.5,
            color: palette.textMuted,
          ),
        ),
      ],
    );
  }
}
