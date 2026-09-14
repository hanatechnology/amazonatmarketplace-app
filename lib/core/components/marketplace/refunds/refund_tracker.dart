import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/date_formatter.dart';
import '../../../utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../presentation/pages/marketplace/refunds/transaction_proof_page.dart';
import '../app_network_image.dart';
import '../orders/order_section_card.dart';
import 'refund_progress_rail.dart';
import 'refund_status_badge.dart';

/// Customer-facing view of an order's refund and payout progress: one block per
/// request, newest first. Renders nothing when there is nothing to track.
class RefundTracker extends StatelessWidget {
  const RefundTracker({super.key, required this.refunds});

  final List<RefundEntity> refunds;

  @override
  Widget build(BuildContext context) {
    if (refunds.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;
    final ordered = [...refunds]
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

    return OrderSectionCard(
      title: LocaleKeys.refundTracking.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < ordered.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: palette.hairline),
              ),
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
    final palette = context.palette;
    final reason = refund.displayReason;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                refund.refundType == RefundType.full
                    ? LocaleKeys.refundTypeFull.tr
                    : LocaleKeys.refundTypePartial.tr,
                style: MarketplaceTypography.rowTitle.copyWith(
                  color: palette.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            RefundStatusBadge(status: refund.status),
          ],
        ),

        // The rail comes first: "where is my refund" is the question this card
        // exists to answer, and a list of amounts does not answer it.
        const SizedBox(height: 12),
        RefundProgressRail(refund: refund),

        // The rail says where the refund is. This says what it is waiting for,
        // which is the half customers actually ask support about.
        if (_nextStepFor(refund.status) != null) ...[
          const SizedBox(height: 12),
          _NextStepNote(text: _nextStepFor(refund.status)!),
        ],

        const SizedBox(height: 12),
        Divider(height: 1, color: palette.hairline),
        const SizedBox(height: 6),
        _Row(
          label: LocaleKeys.refundAmount.tr,
          value: PriceFormatter.formatWithUnit(refund.amount),
          isNumeric: true,
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
            value: PriceFormatter.formatWithUnit(refund.transportCost),
            isNumeric: true,
          ),
        if (refund.payoutMethodName != null)
          _Row(
            label: LocaleKeys.payoutMethod.tr,
            value: refund.payoutMethodName!,
          ),
        if (refund.declineReason != null &&
            refund.declineReason!.isNotEmpty) ...[
          const SizedBox(height: 10),
          _DeclineNote(reason: refund.declineReason!),
        ],
        if (refund.collections.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SubHeading(label: LocaleKeys.pickupSchedule.tr),
          for (final collection in refund.collections)
            _Row(
              label: collection.pickupDate == null
                  ? collection.status
                  : DateFormatter.mediumDate(collection.pickupDate!),
              value: DateFormatter.timeRange(
                    collection.pickupFromTime,
                    collection.pickupToTime,
                  ) ??
                  '',
              // A time window is a Latin run. Left to the paragraph direction
              // it renders as "13:00 – 10:00" in Arabic — the range reversed.
              isNumeric: true,
            ),
        ],
        if (refund.payouts.isNotEmpty) ...[
          const SizedBox(height: 10),
          _SubHeading(label: LocaleKeys.payouts.tr),
          for (final payout in refund.payouts)
            _PayoutRow(payout: payout),
        ],
      ],
    );
  }
}

/// One payout, plus the receipt for it once an operator has uploaded one.
class _PayoutRow extends StatelessWidget {
  const _PayoutRow({required this.payout});

  final RefundPayoutEntity payout;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  PriceFormatter.formatWithUnit(payout.netAmount),
                  textDirection: TextDirection.ltr,
                  style: MarketplaceTypography.rowTitle.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PayoutStatusBadge(status: payout.status),
            ],
          ),
          if (payout.hasTransactionProof) ...[
            const SizedBox(height: 8),
            _TransactionProofTile(imageUrl: payout.transactionImageUrl!),
          ],
        ],
      ),
    );
  }
}

/// The transfer receipt, as a tappable thumbnail.
///
/// A thumbnail rather than a bare "view receipt" link: the customer is looking
/// for evidence their money moved, and seeing the slip — even at 44 points —
/// answers that faster than any label does. Tapping opens it full-screen,
/// where it can be saved.
class _TransactionProofTile extends StatelessWidget {
  const _TransactionProofTile({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.MARKETPLACE_TRANSACTION_PROOF,
        arguments: TransactionProofArgs(imageUrl: imageUrl),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.md),
          border: Border.all(color: palette.hairline),
        ),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: imageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              borderRadius: MarketplaceRadius.sm,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.transactionProof.tr,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    LocaleKeys.transactionProofHint.tr,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      color: palette.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Points into the receipt, so it mirrors with the script.
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  const _SubHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: MarketplaceTypography.labelCaps.copyWith(
          color: context.palette.textMuted,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

/// A rejection needs to read as a rejection in both themes, so it keeps the
/// danger wash rather than the neutral card surface.
class _DeclineNote extends StatelessWidget {
  const _DeclineNote({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final isDark = context.palette.isDark;
    final background =
        isDark ? const Color(0x33D92D20) : const Color(0xFFFDE8E8);
    final foreground =
        isDark ? const Color(0xFFF19C93) : const Color(0xFFB4271C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MarketplaceRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.declineReason.tr.toUpperCase(),
            style: MarketplaceTypography.labelCaps.copyWith(
              color: foreground,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reason,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11.5,
              height: 1.4,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.isNumeric = false,
  });

  final String label;
  final String value;

  /// Money keeps its own direction inside Arabic.
  final bool isNumeric;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: MarketplaceTypography.body.copyWith(
                fontSize: 12,
                color: palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textDirection: isNumeric ? TextDirection.ltr : null,
              style: MarketplaceTypography.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// What the refund is waiting on, in the customer's words.
///
/// Terminal states get nothing: a refunded or rejected request is not waiting
/// for anything, and a "next step" line under it would be a lie.
String? _nextStepFor(RefundStatus status) => switch (status) {
      RefundStatus.pending => LocaleKeys.refundNextPending.tr,
      RefundStatus.underReview => LocaleKeys.refundNextUnderReview.tr,
      RefundStatus.underProcessing => LocaleKeys.refundNextUnderProcessing.tr,
      RefundStatus.awaitingPayout => LocaleKeys.refundNextAwaitingPayout.tr,
      RefundStatus.refunded ||
      RefundStatus.rejected ||
      RefundStatus.unknown =>
        null,
    };

class _NextStepNote extends StatelessWidget {
  const _NextStepNote({required this.text});

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
          Icon(Icons.info_outline_rounded, size: 15, color: palette.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '${LocaleKeys.refundNext.tr}: ',
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: text,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      fontSize: 11,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
