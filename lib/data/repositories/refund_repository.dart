import 'package:marketplace/core/bases/base_list_response.dart';
import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/payout_method_model.dart';
import 'package:marketplace/data/models/marketplace/refund_model.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/entities/marketplace/refund_entity.dart';

/// Body for `POST /orders/{id}/refund`.
///
/// `refund_type`, `reason`, and `payout_method_id` are required by the DTO;
/// `refunded_items` is required only when the type is PARTIAL.
class CreateRefundRequest {
  const CreateRefundRequest({
    required this.refundType,
    required this.reason,
    required this.payoutMethodId,
    this.reasonId,
    this.refundedItems = const [],
    this.payoutDetails = const {},
  });

  final RefundType refundType;
  final String reason;
  final String payoutMethodId;
  final String? reasonId;
  final List<RefundItemRequest> refundedItems;
  final Map<String, String> payoutDetails;

  Map<String, dynamic> toJson() => {
        'refund_type': refundType.wireValue,
        'reason': reason,
        'payout_method_id': payoutMethodId,
        if (reasonId != null && reasonId!.isNotEmpty) 'reason_id': reasonId,
        if (refundType == RefundType.partial)
          'refunded_items':
              refundedItems.map((item) => item.toJson()).toList(),
        if (payoutDetails.isNotEmpty) 'payout_details': payoutDetails,
      };
}

class RefundItemRequest {
  const RefundItemRequest({required this.orderItemId, required this.quantity});

  final String orderItemId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'order_item_id': orderItemId,
        'quantity': quantity,
      };
}

class RefundRepository extends BaseRepository<ApiService> {
  RefundRepository(super.service);

  Future<Result<RefundModel>> requestRefund(
    String orderId,
    CreateRefundRequest request,
  ) {
    return post(
      '/orders/$orderId/refund',
      (json) => BaseResponse.fromJson(
        json as Map<String, dynamic>,
        (data) => RefundModel.fromJson(data as Map<String, dynamic>),
      ).data,
      body: request.toJson(),
    );
  }

  Future<Result<List<RefundReasonModel>>> getRefundReasons() {
    return get(
      '/dropdowns/refund-reasons',
      (json) => BaseListResponse.fromJson(
        json as Map<String, dynamic>,
        (item) => RefundReasonModel.fromJson(item as Map<String, dynamic>),
      ).data,
    );
  }

  Future<Result<List<PayoutMethodModel>>> getPayoutMethods() {
    return get(
      '/dropdowns/payout-methods',
      (json) => BaseListResponse.fromJson(
        json as Map<String, dynamic>,
        (item) => PayoutMethodModel.fromJson(item as Map<String, dynamic>),
      ).data,
    );
  }
}
