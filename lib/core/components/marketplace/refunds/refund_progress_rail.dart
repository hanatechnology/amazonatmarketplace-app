import 'package:flutter/material.dart';

import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/status_tone.dart';
import '../../../utils/date_formatter.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';
import 'refund_status_badge.dart';

/// Vertical rail showing where a refund has got to.
///
/// Laid out as one [Row] per step — a dot column beside its label — so the
/// whole rail mirrors under RTL without a single hard-coded left or right.
///
/// Steps carry dates only where the API actually has one: `requested_at` on the
/// first step and `completed_at` on the terminal one. Every step between them
/// is undated, because no per-transition timestamp exists and inventing one
/// would be worse than showing none.
///
/// The rail draws one dot per backend refund status and nothing else — the
/// statuses are the only progress the API reports, so any step the app invents
/// on top of them is a step that can never complete.
class RefundProgressRail extends StatelessWidget {
  const RefundProgressRail({super.key, required this.refund});

  final RefundEntity refund;

  /// Index of the step a refund is currently on along the happy path, or null
  /// for the statuses that leave it (rejected, unknown).
  ///
  /// One step per backend status, no more: `PENDING` and `UNDER_REVIEW` share
  /// the first dot because they are the same thing to the customer — the
  /// request is in, nobody has ruled on it yet — and a separate "request
  /// received" dot only ever read as a step the refund was still waiting on.
  static int? stepFor(RefundStatus status) => switch (status) {
        RefundStatus.pending || RefundStatus.underReview => 0,
        RefundStatus.underProcessing => 1,
        RefundStatus.awaitingPayout => 2,
        RefundStatus.refunded => 3,
        RefundStatus.rejected || RefundStatus.unknown => null,
      };

  @override
  Widget build(BuildContext context) {
    final isRejected = refund.status == RefundStatus.rejected;

    // Once the money is out, the rail is history: every dot goes green,
    // including the last one, so nothing on a finished refund still reads as
    // in-flight.
    final isComplete = refund.status == RefundStatus.refunded;

    // A rejection stops the rail early: there is no payout leg to draw, and
    // showing greyed-out steps after it implies the request is still moving.
    final labels = isRejected
        ? [
            RefundStatusBadge.labelFor(RefundStatus.underReview),
            RefundStatusBadge.labelFor(RefundStatus.rejected),
          ]
        : [
            RefundStatusBadge.labelFor(RefundStatus.underReview),
            RefundStatusBadge.labelFor(RefundStatus.underProcessing),
            RefundStatusBadge.labelFor(RefundStatus.awaitingPayout),
            RefundStatusBadge.labelFor(RefundStatus.refunded),
          ];

    final current = isRejected ? labels.length - 1 : (stepFor(refund.status) ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++)
          _Step(
            label: labels[i],
            date: _dateFor(i, labels.length, isRejected),
            isDone: isComplete || i < current,
            isCurrent: !isComplete && i == current,
            isTerminalBad: isRejected && i == labels.length - 1,
            isLast: i == labels.length - 1,
          ),
      ],
    );
  }

  String? _dateFor(int index, int count, bool isRejected) {
    if (index == 0) return DateFormatter.mediumDate(refund.requestedAt);
    final completedAt = refund.completedAt;
    if (completedAt == null) return null;
    final isTerminal = index == count - 1;
    final reachedTerminal =
        isRejected || refund.status == RefundStatus.refunded;
    if (isTerminal && reachedTerminal) {
      return DateFormatter.mediumDate(completedAt);
    }
    return null;
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.date,
    required this.isDone,
    required this.isCurrent,
    required this.isTerminalBad,
    required this.isLast,
  });

  final String label;
  final String? date;
  final bool isDone;
  final bool isCurrent;
  final bool isTerminalBad;
  final bool isLast;

  static const double _dotSize = 18;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;
    final reached = isDone || isCurrent || isTerminalBad;

    final done = StatusTone.success.foreground(isDark);
    final live = StatusTone.info.foreground(isDark);
    final bad = StatusTone.danger.foreground(isDark);

    final Color fill;
    if (isTerminalBad) {
      fill = bad;
    } else if (isDone) {
      fill = done;
    } else if (isCurrent) {
      fill = live;
    } else {
      fill = palette.surface;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _dotSize,
            child: Column(
              children: [
                Container(
                  width: _dotSize,
                  height: _dotSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: reached ? fill : palette.hairline,
                      width: 2,
                    ),
                    boxShadow: isCurrent && !isTerminalBad
                        ? [
                            BoxShadow(
                              color: StatusTone.info.background(isDark),
                              spreadRadius: 3.5,
                            ),
                          ]
                        : null,
                  ),
                  child: isDone
                      ? Icon(Icons.check_rounded,
                          size: 12, color: palette.surface)
                      : isTerminalBad
                          ? Icon(Icons.priority_high_rounded,
                              size: 12, color: palette.surface)
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: isDone ? done : palette.hairline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: MarketplaceTypography.cardHeading.copyWith(
                      color: reached ? palette.textPrimary : palette.textMuted,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      date!,
                      style: MarketplaceTypography.rowMeta.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
