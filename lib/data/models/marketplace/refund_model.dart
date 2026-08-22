import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/refund_entity.dart';

bool _isArabic() => Get.locale?.languageCode == 'ar';

/// Picks the label for the active locale, falling back to the other language
/// when only one was filled in.
String _localized(String? ar, String? en) {
  final arabic = ar ?? '';
  final english = en ?? '';
  return _isArabic()
      ? (arabic.isNotEmpty ? arabic : english)
      : (english.isNotEmpty ? english : arabic);
}

class RefundPayoutModel {
  const RefundPayoutModel({
    required this.id,
    required this.status,
    required this.netAmount,
    required this.requestedAt,
    this.processedAt,
    this.payoutMethodNameAr,
    this.payoutMethodNameEn,
  });

  final String id;
  final String status;
  final String netAmount;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? payoutMethodNameAr;
  final String? payoutMethodNameEn;

  factory RefundPayoutModel.fromJson(Map<String, dynamic> json) {
    final method = json['payoutMethod'] as Map<String, dynamic>?;
    return RefundPayoutModel(
      id: json['id'].toString(),
      status: json['status'] as String? ?? '',
      netAmount: json['net_amount']?.toString() ?? '0',
      requestedAt:
          DateTime.tryParse(json['requested_at'] as String? ?? '') ??
              DateTime.now(),
      processedAt: DateTime.tryParse(json['processed_at'] as String? ?? ''),
      payoutMethodNameAr: method?['name_ar'] as String?,
      payoutMethodNameEn: method?['name_en'] as String?,
    );
  }

  RefundPayoutEntity toEntity() {
    final name = _localized(payoutMethodNameAr, payoutMethodNameEn);
    return RefundPayoutEntity(
      id: id,
      status: PayoutStatus.fromWire(status),
      netAmount: double.tryParse(netAmount) ?? 0,
      requestedAt: requestedAt,
      processedAt: processedAt,
      payoutMethodName: name.isEmpty ? null : name,
    );
  }
}

class RefundCollectionModel {
  const RefundCollectionModel({
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

  factory RefundCollectionModel.fromJson(Map<String, dynamic> json) {
    return RefundCollectionModel(
      id: json['id'].toString(),
      status: json['status'] as String? ?? '',
      pickupDate: DateTime.tryParse(json['pickup_date'] as String? ?? ''),
      pickupFromTime: json['pickup_from_time'] as String?,
      pickupToTime: json['pickup_to_time'] as String?,
      pickedUpAt: DateTime.tryParse(json['picked_up_at'] as String? ?? ''),
      deliveredAt: DateTime.tryParse(json['delivered_at'] as String? ?? ''),
    );
  }

  RefundCollectionEntity toEntity() => RefundCollectionEntity(
        id: id,
        status: status,
        pickupDate: pickupDate,
        pickupFromTime: pickupFromTime,
        pickupToTime: pickupToTime,
        pickedUpAt: pickedUpAt,
        deliveredAt: deliveredAt,
      );
}

/// Wire model for one entry of the `refunds` array on `GET /orders/{id}`, and
/// for the `POST /orders/{id}/refund` response.
class RefundModel {
  const RefundModel({
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
  final String refundType;
  final String status;
  final String amount;
  final DateTime requestedAt;
  final String transportCost;
  final String? reason;
  final String? declineReason;
  final DateTime? completedAt;
  final String? reasonLabelAr;
  final String? reasonLabelEn;
  final String? payoutMethodNameAr;
  final String? payoutMethodNameEn;
  final List<RefundPayoutModel> payouts;
  final List<RefundCollectionModel> collections;

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    final reason = json['refundReason'] as Map<String, dynamic>?;
    final method = json['payoutMethod'] as Map<String, dynamic>?;

    return RefundModel(
      id: json['id'].toString(),
      refundType: json['refund_type'] as String? ?? 'FULL',
      status: json['status'] as String? ?? '',
      amount: json['amount']?.toString() ?? '0',
      requestedAt:
          DateTime.tryParse(json['requested_at'] as String? ?? '') ??
              DateTime.now(),
      transportCost: json['transport_cost']?.toString() ?? '0',
      reason: json['reason'] as String?,
      declineReason: json['decline_reason'] as String?,
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
      reasonLabelAr: reason?['label_ar'] as String?,
      reasonLabelEn: reason?['label_en'] as String?,
      payoutMethodNameAr: method?['name_ar'] as String?,
      payoutMethodNameEn: method?['name_en'] as String?,
      payouts: (json['payouts'] as List<dynamic>? ?? const [])
          .map((item) =>
              RefundPayoutModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      collections: (json['collection_orders'] as List<dynamic>? ?? const [])
          .map((item) =>
              RefundCollectionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  RefundEntity toEntity() {
    final label = _localized(reasonLabelAr, reasonLabelEn);
    final methodName = _localized(payoutMethodNameAr, payoutMethodNameEn);

    return RefundEntity(
      id: id,
      refundType: RefundType.fromWire(refundType),
      status: RefundStatus.fromWire(status),
      amount: double.tryParse(amount) ?? 0,
      requestedAt: requestedAt,
      transportCost: double.tryParse(transportCost) ?? 0,
      reason: reason,
      declineReason: declineReason,
      completedAt: completedAt,
      reasonLabel: label.isEmpty ? null : label,
      payoutMethodName: methodName.isEmpty ? null : methodName,
      payouts: payouts.map((payout) => payout.toEntity()).toList(),
      collections:
          collections.map((collection) => collection.toEntity()).toList(),
    );
  }
}

/// Wire model for `GET /dropdowns/refund-reasons`.
class RefundReasonModel {
  const RefundReasonModel({
    required this.id,
    required this.labelAr,
    required this.labelEn,
  });

  final String id;
  final String labelAr;
  final String labelEn;

  factory RefundReasonModel.fromJson(Map<String, dynamic> json) {
    return RefundReasonModel(
      id: json['id'].toString(),
      labelAr: json['label_ar'] as String? ?? '',
      labelEn: json['label_en'] as String? ?? '',
    );
  }

  RefundReasonEntity toEntity() => RefundReasonEntity(
        id: id,
        label: _localized(labelAr, labelEn),
      );
}
