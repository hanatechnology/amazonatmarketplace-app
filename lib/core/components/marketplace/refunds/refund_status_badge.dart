import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/status_tone.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';

/// Pill for a refund's status. Colour grouping follows the web client.
class RefundStatusBadge extends StatelessWidget {
  const RefundStatusBadge({super.key, required this.status});

  final RefundStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusPill(label: labelFor(status), tone: toneFor(status));
  }

  /// Public so a card can tint a refund chip with the same tone the pill
  /// uses — one status must never mean two colours.
  static StatusTone toneFor(RefundStatus status) => switch (status) {
        RefundStatus.pending || RefundStatus.underReview => StatusTone.warning,
        RefundStatus.underProcessing ||
        RefundStatus.awaitingPayout =>
          StatusTone.info,
        RefundStatus.refunded => StatusTone.success,
        RefundStatus.rejected => StatusTone.danger,
        RefundStatus.unknown => StatusTone.neutral,
      };

  static String labelFor(RefundStatus status) => switch (status) {
        RefundStatus.pending => LocaleKeys.refundStatusPending.tr,
        RefundStatus.underProcessing =>
          LocaleKeys.refundStatusUnderProcessing.tr,
        RefundStatus.underReview => LocaleKeys.refundStatusUnderReview.tr,
        RefundStatus.awaitingPayout => LocaleKeys.refundStatusAwaitingPayout.tr,
        RefundStatus.rejected => LocaleKeys.refundStatusRejected.tr,
        RefundStatus.refunded => LocaleKeys.refundStatusRefunded.tr,
        RefundStatus.unknown => LocaleKeys.statusUnknown.tr,
      };
}

/// Pill for one payout's status.
class PayoutStatusBadge extends StatelessWidget {
  const PayoutStatusBadge({super.key, required this.status});

  final PayoutStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusPill(label: _label(status), tone: _tone(status));
  }

  static StatusTone _tone(PayoutStatus status) => switch (status) {
        PayoutStatus.pending => StatusTone.warning,
        PayoutStatus.processing => StatusTone.info,
        PayoutStatus.approved || PayoutStatus.completed => StatusTone.success,
        PayoutStatus.declined => StatusTone.danger,
        PayoutStatus.unknown => StatusTone.neutral,
      };

  static String _label(PayoutStatus status) => switch (status) {
        PayoutStatus.pending => LocaleKeys.payoutStatusPending.tr,
        PayoutStatus.processing => LocaleKeys.payoutStatusProcessing.tr,
        PayoutStatus.approved => LocaleKeys.payoutStatusApproved.tr,
        PayoutStatus.completed => LocaleKeys.payoutStatusCompleted.tr,
        PayoutStatus.declined => LocaleKeys.payoutStatusDeclined.tr,
        PayoutStatus.unknown => LocaleKeys.statusUnknown.tr,
      };
}
