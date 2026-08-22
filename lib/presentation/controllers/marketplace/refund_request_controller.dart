import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/data/repositories/refund_repository.dart';
import 'package:marketplace/domain/entities/marketplace/order_entity.dart';
import 'package:marketplace/domain/entities/marketplace/payout_method_entity.dart';
import 'package:marketplace/domain/entities/marketplace/refund_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/refund/get_payout_methods_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/refund/get_refund_reasons_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/refund/request_refund_use_case.dart';
import 'order_details_controller.dart';

/// Per-item selection state for a partial refund.
class RefundItemSelection {
  RefundItemSelection({required this.selected, required this.quantity});

  bool selected;
  int quantity;
}

const String kRefundReasons = 'refundReasons';
const String kPayoutMethods = 'payoutMethods';
const String kSubmitRefund = 'submitRefund';

/// Drives the refund request form.
///
/// The order is passed in whole via `Get.arguments` — the form needs its items
/// for a partial refund, and re-fetching it would be a second round trip for
/// data the caller already has.
class RefundRequestController
    extends BaseStateController<GetRefundReasonsUseCase> {
  late OrderEntity order;

  final refundType = RefundType.full.obs;
  final selectedReasonId = RxnString();
  final selectedPayoutMethodId = RxnString();
  final reasonController = TextEditingController();

  /// order item id → selection
  final itemSelections = <String, RefundItemSelection>{}.obs;

  /// payout field key → controller
  final Map<String, TextEditingController> payoutControllers = {};

  /// payout field key → current value, for SELECT fields with no text input
  final payoutValues = <String, String>{}.obs;

  final reasonError = RxnString();
  final itemsError = RxnString();
  final payoutMethodError = RxnString();
  final payoutFieldErrors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    order = Get.arguments as OrderEntity;
    for (final item in order.items) {
      itemSelections[item.id] =
          RefundItemSelection(selected: false, quantity: item.quantity);
    }
    loadReasons();
    loadPayoutMethods();
  }

  @override
  void onClose() {
    reasonController.dispose();
    for (final controller in payoutControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  // ── Loading ───────────────────────────────────────────────

  Future<void> loadReasons() => handleState<List<RefundReasonEntity>>(
        kRefundReasons,
        () => useCase.execute(),
      );

  Future<void> loadPayoutMethods() => handleState<List<PayoutMethodEntity>>(
        kPayoutMethods,
        () => Get.find<GetPayoutMethodsUseCase>().execute(),
      );

  List<RefundReasonEntity> get reasons =>
      getOperationData<List<RefundReasonEntity>>(kRefundReasons) ?? const [];

  List<PayoutMethodEntity> get payoutMethods =>
      getOperationData<List<PayoutMethodEntity>>(kPayoutMethods) ?? const [];

  PayoutMethodEntity? get selectedPayoutMethod {
    final id = selectedPayoutMethodId.value;
    if (id == null) return null;
    for (final method in payoutMethods) {
      if (method.id == id) return method;
    }
    return null;
  }

  bool get isSubmitting => getState<RefundEntity>(kSubmitRefund).isLoading;

  // ── Form mutations ────────────────────────────────────────

  void changeType(RefundType type) {
    refundType.value = type;
    itemsError.value = null;
  }

  void selectReason(String? id) {
    selectedReasonId.value = id;
    reasonError.value = null;
  }

  /// Switching method clears the previous method's answers — the field sets
  /// are unrelated, and stale keys would be sent as `payout_details`.
  void selectPayoutMethod(String id) {
    if (selectedPayoutMethodId.value == id) return;
    selectedPayoutMethodId.value = id;
    payoutMethodError.value = null;
    payoutFieldErrors.clear();
    payoutValues.clear();
    for (final controller in payoutControllers.values) {
      controller.dispose();
    }
    payoutControllers.clear();

    for (final field in selectedPayoutMethod?.fields ?? const []) {
      if (field.fieldType != PayoutFieldType.select) {
        payoutControllers[field.fieldKey] = TextEditingController();
      }
    }
  }

  void setPayoutValue(String fieldKey, String value) {
    payoutValues[fieldKey] = value;
    if (payoutFieldErrors.containsKey(fieldKey)) {
      payoutFieldErrors.remove(fieldKey);
    }
  }

  void toggleItem(String itemId, bool selected) {
    final selection = itemSelections[itemId];
    if (selection == null) return;
    selection.selected = selected;
    itemSelections.refresh();
    itemsError.value = null;
  }

  void changeItemQuantity(String itemId, int quantity) {
    final selection = itemSelections[itemId];
    if (selection == null) return;
    final max = order.items.firstWhere((item) => item.id == itemId).quantity;
    selection.quantity = quantity.clamp(1, max);
    itemSelections.refresh();
  }

  // ── Validation ────────────────────────────────────────────

  /// Mirrors the web's `validatePayoutFields`: required first, then the
  /// backend-supplied regex. An unparseable regex is skipped rather than
  /// blocking submission.
  Map<String, String> _validatePayoutFields() {
    final errors = <String, String>{};
    final method = selectedPayoutMethod;
    if (method == null) return errors;

    for (final field in method.fields) {
      final value = _payoutValueFor(field.fieldKey).trim();

      if (field.isRequired && value.isEmpty) {
        errors[field.fieldKey] = LocaleKeys.fieldRequired.tr;
        continue;
      }
      if (value.isEmpty) continue;

      final pattern = field.validationRegex;
      if (pattern == null || pattern.isEmpty) continue;
      try {
        if (!RegExp(pattern).hasMatch(value)) {
          errors[field.fieldKey] =
              field.validationMessage ?? LocaleKeys.fieldInvalid.tr;
        }
      } on FormatException {
        // Backend shipped an invalid regex — do not block the customer.
      }
    }
    return errors;
  }

  String _payoutValueFor(String fieldKey) =>
      payoutControllers[fieldKey]?.text ?? payoutValues[fieldKey] ?? '';

  bool _validate() {
    var valid = true;

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      reasonError.value = LocaleKeys.fieldRequired.tr;
      valid = false;
    }

    if (refundType.value == RefundType.partial && _selectedItems.isEmpty) {
      itemsError.value = LocaleKeys.selectAtLeastOneItem.tr;
      valid = false;
    }

    if (selectedPayoutMethodId.value == null) {
      payoutMethodError.value = LocaleKeys.fieldRequired.tr;
      valid = false;
    }

    final fieldErrors = _validatePayoutFields();
    if (fieldErrors.isNotEmpty) {
      payoutFieldErrors.assignAll(fieldErrors);
      valid = false;
    }

    return valid;
  }

  List<RefundItemRequest> get _selectedItems => itemSelections.entries
      .where((entry) => entry.value.selected && entry.value.quantity > 0)
      .map((entry) => RefundItemRequest(
            orderItemId: entry.key,
            quantity: entry.value.quantity,
          ))
      .toList();

  // ── Submit ────────────────────────────────────────────────

  Future<void> submit() async {
    if (!_validate()) return;

    final details = <String, String>{};
    for (final field in selectedPayoutMethod?.fields ?? const []) {
      final value = _payoutValueFor(field.fieldKey).trim();
      if (value.isNotEmpty) details[field.fieldKey] = value;
    }

    await handleState<RefundEntity>(
      kSubmitRefund,
      () => Get.find<RequestRefundUseCase>().call(
        RequestRefundInput(
          orderId: order.id,
          request: CreateRefundRequest(
            refundType: refundType.value,
            reason: reasonController.text.trim(),
            payoutMethodId: selectedPayoutMethodId.value!,
            reasonId: selectedReasonId.value,
            refundedItems: _selectedItems,
            payoutDetails: details,
          ),
        ),
      ),
      onSuccess: (_, __) {
        // Reload the order so the tracker and the hidden request button both
        // reflect the new refund.
        if (Get.isRegistered<OrderDetailsController>()) {
          Get.find<OrderDetailsController>().refreshOrderDetails();
        }
        Get.back();
        Get.snackbar(
          LocaleKeys.refundRequested.tr,
          LocaleKeys.refundRequestedMessage.tr,
        );
      },
    );
  }
}
