import 'package:equatable/equatable.dart';
import 'package:marketplace/core/utils/localized_copy.dart';

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
    this.payoutMethodNameAr,
    this.payoutMethodNameEn,
    this.transactionImageUrl,
  });

  final String id;
  final PayoutStatus status;
  final double netAmount;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? payoutMethodNameAr;
  final String? payoutMethodNameEn;

  /// Bank or wallet transfer receipt uploaded by the operator when the payout
  /// was executed. Absent until then, and absent on a declined payout.
  final String? transactionImageUrl;

  String? get payoutMethodName =>
      localizedCopy(payoutMethodNameAr, payoutMethodNameEn);

  /// True when there is a receipt worth offering the customer.
  bool get hasTransactionProof =>
      transactionImageUrl != null && transactionImageUrl!.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        status,
        netAmount,
        requestedAt,
        processedAt,
        payoutMethodNameAr,
        payoutMethodNameEn,
        transactionImageUrl,
      ];
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
    this.reasonLabelAr,
    this.reasonLabelEn,
    this.payoutMethodNameAr,
    this.payoutMethodNameEn,
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

  final String? reasonLabelAr;
  final String? reasonLabelEn;
  final String? payoutMethodNameAr;
  final String? payoutMethodNameEn;
  final List<RefundPayoutEntity> payouts;
  final List<RefundCollectionEntity> collections;

  /// Label of the picked reason in the language showing right now.
  String? get reasonLabel => localizedCopy(reasonLabelAr, reasonLabelEn);

  String? get payoutMethodName =>
      localizedCopy(payoutMethodNameAr, payoutMethodNameEn);

  /// The reason label, falling back to the customer's own free-text [reason].
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
        reasonLabelAr,
        reasonLabelEn,
        payoutMethodNameAr,
        payoutMethodNameEn,
        payouts,
        collections,
      ];
}

/// One entry from `GET /dropdowns/refund-reasons`.
class RefundReasonEntity extends Equatable {
  const RefundReasonEntity({
    required this.id,
    required this.labelAr,
    required this.labelEn,
  });

  final String id;
  final String labelAr;
  final String labelEn;

  String get label => localizedCopy(labelAr, labelEn) ?? '';

  @override
  List<Object?> get props => [id, labelAr, labelEn];
}
