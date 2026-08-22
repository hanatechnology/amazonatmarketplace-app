import 'package:equatable/equatable.dart';

/// Lifecycle of a refund request.
enum RefundStatus {
  pending,
  underProcessing,
  underReview,
  awaitingPayout,
  rejected,
  refunded,
  unknown;

  static RefundStatus fromWire(String? value) => switch (value) {
        'PENDING' => RefundStatus.pending,
        'UNDER_PROCESSING' => RefundStatus.underProcessing,
        'UNDER_REVIEW' => RefundStatus.underReview,
        'AWAITING_PAYOUT' => RefundStatus.awaitingPayout,
        'REJECTED' => RefundStatus.rejected,
        'REFUNDED' => RefundStatus.refunded,
        _ => RefundStatus.unknown,
      };

  /// States that mean the request is still being handled. One of these blocks a
  /// second request on the same order; the terminal states (rejected, refunded)
  /// deliberately do not, so a customer can re-request after a rejection.
  bool get isActive =>
      this == RefundStatus.pending ||
      this == RefundStatus.underProcessing ||
      this == RefundStatus.underReview ||
      this == RefundStatus.awaitingPayout;
}

enum RefundType {
  full,
  partial;

  String get wireValue => this == RefundType.full ? 'FULL' : 'PARTIAL';

  static RefundType fromWire(String? value) =>
      value == 'PARTIAL' ? RefundType.partial : RefundType.full;
}

enum PayoutStatus {
  pending,
  processing,
  approved,
  completed,
  declined,
  unknown;

  static PayoutStatus fromWire(String? value) => switch (value) {
        'PENDING' => PayoutStatus.pending,
        'PROCESSING' => PayoutStatus.processing,
        'APPROVED' => PayoutStatus.approved,
        'COMPLETED' => PayoutStatus.completed,
        'DECLINED' => PayoutStatus.declined,
        _ => PayoutStatus.unknown,
      };
}

/// A payout issued against a refund.
class RefundPayoutEntity extends Equatable {
  const RefundPayoutEntity({
    required this.id,
    required this.status,
    required this.netAmount,
    required this.requestedAt,
    this.processedAt,
    this.payoutMethodName,
  });

  final String id;
  final PayoutStatus status;
  final double netAmount;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? payoutMethodName;

  @override
  List<Object?> get props =>
      [id, status, netAmount, requestedAt, processedAt, payoutMethodName];
}

/// A scheduled pickup of the returned goods.
class RefundCollectionEntity extends Equatable {
  const RefundCollectionEntity({
    required this.id,
    required this.status,
    this.pickupDate,
    this.pickupFromTime,
    this.pickupToTime,
    this.pickedUpAt,
    this.deliveredAt,
  });

  final String id;
  final String status;
  final DateTime? pickupDate;
  final String? pickupFromTime;
  final String? pickupToTime;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  @override
  List<Object?> get props => [
        id,
        status,
        pickupDate,
        pickupFromTime,
        pickupToTime,
        pickedUpAt,
        deliveredAt,
      ];
}

/// One refund request on an order, as returned by `GET /orders/{id}`.
class RefundEntity extends Equatable {
  const RefundEntity({
    required this.id,
    required this.refundType,
    required this.status,
    required this.amount,
    required this.requestedAt,
    required this.transportCost,
    this.reason,
    this.declineReason,
    this.completedAt,
    this.reasonLabel,
    this.payoutMethodName,
    this.payouts = const [],
    this.collections = const [],
  });

  final String id;
  final RefundType refundType;
  final RefundStatus status;
  final double amount;
  final DateTime requestedAt;
  final double transportCost;
  final String? reason;
  final String? declineReason;
  final DateTime? completedAt;

  /// Localized label of the picked reason; falls back to the free-text [reason].
  final String? reasonLabel;
  final String? payoutMethodName;
  final List<RefundPayoutEntity> payouts;
  final List<RefundCollectionEntity> collections;

  String? get displayReason {
    final label = reasonLabel;
    if (label != null && label.isNotEmpty) return label;
    return reason;
  }

  @override
  List<Object?> get props => [
        id,
        refundType,
        status,
        amount,
        requestedAt,
        transportCost,
        reason,
        declineReason,
        completedAt,
        reasonLabel,
        payoutMethodName,
        payouts,
        collections,
      ];
}

/// One entry from `GET /dropdowns/refund-reasons`.
class RefundReasonEntity extends Equatable {
  const RefundReasonEntity({required this.id, required this.label});

  final String id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}
