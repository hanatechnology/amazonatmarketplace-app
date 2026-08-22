import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/date_formatter.dart';
import '../../../utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';
import 'refund_status_badge.dart';

/// Customer-facing view of an order's refund and payout progress: one block per
/// request, newest first. Renders nothing when there is nothing to track.
class RefundTracker extends StatelessWidget {
  const RefundTracker({super.key, required this.refunds});

  final List<RefundEntity> refunds;

  @override
  Widget build(BuildContext context) {
    if (refunds.isEmpty) return const SizedBox.shrink();

    final ordered = [...refunds]
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

    return Container(
      padding: const EdgeInsets.all(MarketplaceSpacing.md),
      decoration: BoxDecoration(
        color: MarketplaceColors.surface,
        borderRadius: BorderRadius.circular(MarketplaceRadius.card),
        border: Border.all(color: MarketplaceColors.strokeLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.refundTracker.tr,
            style: MarketplaceTypography.cardTitle,
          ),
          for (var i = 0; i < ordered.length; i++) ...[
            if (i > 0)
              const Divider(color: MarketplaceColors.strokeLight),
            _RefundBlock(refund: ordered[i]),
          ],
        ],
      ),
    );
  }
}

class _RefundBlock extends StatelessWidget {
  const _RefundBlock({required this.refund});

  final RefundEntity refund;

  @override
  Widget build(BuildContext context) {
    final reason = refund.displayReason;

    return Padding(
      padding: const EdgeInsets.only(top: MarketplaceSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  refund.refundType == RefundType.full
                      ? LocaleKeys.refundTypeFull.tr
                      : LocaleKeys.refundTypePartial.tr,
                  style: MarketplaceTypography.bodyBold,
                ),
              ),
              RefundStatusBadge(status: refund.status),
            ],
          ),
          const SizedBox(height: MarketplaceSpacing.xs),
          _Row(
            label: LocaleKeys.refundAmount.tr,
            value: PriceFormatter.format(refund.amount),
          ),
          _Row(
            label: LocaleKeys.refundRequestedAt.tr,
            value: DateFormatter.mediumDate(refund.requestedAt),
          ),
          if (reason != null && reason.isNotEmpty)
            _Row(label: LocaleKeys.refundReason.tr, value: reason),
          if (refund.completedAt != null)
            _Row(
              label: LocaleKeys.refundCompletedAt.tr,
              value: DateFormatter.mediumDate(refund.completedAt!),
            ),
          if (refund.transportCost > 0)
            _Row(
              label: LocaleKeys.transportCost.tr,
              value: PriceFormatter.format(refund.transportCost),
            ),
          if (refund.payoutMethodName != null)
            _Row(
              label: LocaleKeys.payoutMethod.tr,
              value: refund.payoutMethodName!,
            ),
          if (refund.declineReason != null &&
              refund.declineReason!.isNotEmpty) ...[
            const SizedBox(height: MarketplaceSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MarketplaceSpacing.sm),
              decoration: BoxDecoration(
                color: MarketplaceColors.errorSurface,
                borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.declineReason.tr,
                    style: MarketplaceTypography.micro.copyWith(
                      color: MarketplaceColors.errorContent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    refund.declineReason!,
                    style: MarketplaceTypography.micro.copyWith(
                      color: MarketplaceColors.errorContent,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (refund.collections.isNotEmpty) ...[
            const SizedBox(height: MarketplaceSpacing.sm),
            Text(
              LocaleKeys.pickupSchedule.tr,
              style: MarketplaceTypography.micro.copyWith(
                color: MarketplaceColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final collection in refund.collections)
              _Row(
                label: collection.pickupDate == null
                    ? collection.status
                    : DateFormatter.mediumDate(collection.pickupDate!),
                value: [collection.pickupFromTime, collection.pickupToTime]
                    .whereType<String>()
                    .join(' – '),
              ),
          ],
          if (refund.payouts.isNotEmpty) ...[
            const SizedBox(height: MarketplaceSpacing.sm),
            Text(
              LocaleKeys.payouts.tr,
              style: MarketplaceTypography.micro.copyWith(
                color: MarketplaceColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final payout in refund.payouts)
              Padding(
                padding: const EdgeInsets.only(top: MarketplaceSpacing.xxs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        PriceFormatter.format(payout.netAmount),
                        style: MarketplaceTypography.bodyBold,
                      ),
                    ),
                    PayoutStatusBadge(status: payout.status),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MarketplaceSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: MarketplaceTypography.descriptionBody),
          ),
          const SizedBox(width: MarketplaceSpacing.sm),
          Flexible(
            child: Text(
              value,
              style: MarketplaceTypography.bodyBold,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
