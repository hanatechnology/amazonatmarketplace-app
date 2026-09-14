import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/date_formatter.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';
import 'refund_status_badge.dart';

/// The refund's state, called out directly under the order's status pill.
///
/// This is what makes a refund trackable at all: the customer never has to know
/// a tracker exists, because the state of their money is on the screen they
/// already open. Buried at the bottom of the page — where the tracker card used
/// to sit, below the items — it was reachable only by scrolling past everything
/// that was not the reason they came.
class RefundStrip extends StatelessWidget {
  const RefundStrip({super.key, required this.refund, this.onTap});

  final RefundEntity refund;

  /// Jumps to the tracker card. Null makes the strip a plain notice.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;
    final tone = RefundStatusBadge.toneFor(refund.status);
    final foreground = tone.foreground(isDark);

    final type = refund.refundType == RefundType.full
        ? LocaleKeys.refundTypeFull.tr
        : LocaleKeys.refundTypePartial.tr;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: tone.background(isDark),
          borderRadius: BorderRadius.circular(MarketplaceRadius.md + 2),
        ),
        child: Row(
          children: [
            Icon(Icons.assignment_return_outlined, size: 17, color: foreground),
            const SizedBox(width: MarketplaceSpacing.sm + 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$type · ${RefundStatusBadge.labelFor(refund.status)}',
                    style: MarketplaceTypography.cardHeading.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _subtitle(),
                    style: MarketplaceTypography.rowMeta.copyWith(
                      fontSize: 10.5,
                      height: 1.35,
                      color: foreground.withValues(alpha: 0.85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: MarketplaceSpacing.sm),
              Text(
                LocaleKeys.refundTrack.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              // Points at the tracker below, so it flips with the script.
              Icon(Icons.chevron_right_rounded, size: 16, color: foreground),
            ],
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final completedAt = refund.completedAt;
    if (refund.status == RefundStatus.refunded && completedAt != null) {
      return '${LocaleKeys.refundCompletedAt.tr} · '
          '${DateFormatter.mediumDate(completedAt)}';
    }
    if (refund.status == RefundStatus.rejected) {
      return refund.declineReason?.trim().isNotEmpty == true
          ? refund.declineReason!.trim()
          : LocaleKeys.declineReason.tr;
    }
    return '${LocaleKeys.refundRequestedShort.tr} · '
        '${DateFormatter.mediumDate(refund.requestedAt)}';
  }
}

/// Shown on a delivered order that has no refund yet.
///
/// A bare "Request refund" button asks the customer to commit to a process they
/// know nothing about. These two lines say what actually happens — someone
/// collects the goods, then the money moves — so the button below is a decision
/// rather than a leap.
class RefundEligibleCard extends StatelessWidget {
  const RefundEligibleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.refundEligibleLead.tr.toUpperCase(),
            style: MarketplaceTypography.labelCaps.copyWith(
              color: palette.textMuted,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            LocaleKeys.refundEligibleTitle.tr,
            style: MarketplaceTypography.rowTitle.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          _Step(
            icon: Icons.inventory_2_outlined,
            text: LocaleKeys.refundEligibleCollect.tr,
          ),
          const SizedBox(height: 7),
          _Step(
            icon: Icons.account_balance_outlined,
            text: LocaleKeys.refundEligibleMoney.tr,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(MarketplaceRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: palette.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11,
                height: 1.45,
                color: palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
