import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';

/// Pill for a refund's status. Colour grouping follows the web client.
class RefundStatusBadge extends StatelessWidget {
  const RefundStatusBadge({super.key, required this.status});

  final RefundStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      RefundStatus.pending || RefundStatus.underReview => (
          MarketplaceColors.warningSurface,
          MarketplaceColors.warningContent,
        ),
      RefundStatus.underProcessing || RefundStatus.awaitingPayout => (
          MarketplaceColors.infoSurface,
          MarketplaceColors.infoContent,
        ),
      RefundStatus.refunded => (
          MarketplaceColors.successSurface,
          MarketplaceColors.successContent,
        ),
      RefundStatus.rejected => (
          MarketplaceColors.errorSurface,
          MarketplaceColors.errorContent,
        ),
      RefundStatus.unknown => (
          MarketplaceColors.neutralSurface,
          MarketplaceColors.neutralContent,
        ),
    };

    return _Pill(
      label: _label(status),
      background: background,
      foreground: foreground,
    );
  }

  static String _label(RefundStatus status) => switch (status) {
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
    final (background, foreground) = switch (status) {
      PayoutStatus.pending => (
          MarketplaceColors.warningSurface,
          MarketplaceColors.warningContent,
        ),
      PayoutStatus.processing => (
          MarketplaceColors.infoSurface,
          MarketplaceColors.infoContent,
        ),
      PayoutStatus.approved || PayoutStatus.completed => (
          MarketplaceColors.successSurface,
          MarketplaceColors.successContent,
        ),
      PayoutStatus.declined => (
          MarketplaceColors.errorSurface,
          MarketplaceColors.errorContent,
        ),
      PayoutStatus.unknown => (
          MarketplaceColors.neutralSurface,
          MarketplaceColors.neutralContent,
        ),
    };

    return _Pill(
      label: _label(status),
      background: background,
      foreground: foreground,
    );
  }

  static String _label(PayoutStatus status) => switch (status) {
        PayoutStatus.pending => LocaleKeys.payoutStatusPending.tr,
        PayoutStatus.processing => LocaleKeys.payoutStatusProcessing.tr,
        PayoutStatus.approved => LocaleKeys.payoutStatusApproved.tr,
        PayoutStatus.completed => LocaleKeys.payoutStatusCompleted.tr,
        PayoutStatus.declined => LocaleKeys.payoutStatusDeclined.tr,
        PayoutStatus.unknown => LocaleKeys.statusUnknown.tr,
      };
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.sm,
        vertical: MarketplaceSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MarketplaceRadius.badge),
      ),
      child: Text(
        label,
        style: MarketplaceTypography.micro.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
