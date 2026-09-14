import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/errors/exceptions.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/domain/entities/marketplace/checkout_args.dart';
import 'package:marketplace/domain/entities/marketplace/edfali_payment_entity.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/confirm_edfali_payment_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/cart/get_edfali_payment_status_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/order/cancel_order_use_case.dart';

/// Arguments for the Edfali confirm screen.
class EdfaliConfirmArgs {
  const EdfaliConfirmArgs({
    required this.orderId,
    required this.total,
    this.orderNumber,
    this.otpSentTo,
    this.expiresInSeconds,
  });

  final String orderId;
  final double total;

  /// Customer-facing number, shown on the held-order line. Null when the
  /// checkout response did not carry one.
  final String? orderNumber;

  final String? otpSentTo;
  final int? expiresInSeconds;
}

const String kConfirmEdfali = 'confirmEdfali';
const String kEdfaliStatus = 'edfaliStatus';
const String kCancelHeldOrder = 'cancelHeldOrder';

/// Step two of the Edfali flow: collect the four-digit SMS PIN and confirm.
///
/// The PIN is four digits — unrelated to the six-digit login OTP.
class EdfaliConfirmController
    extends BaseStateController<ConfirmEdfaliPaymentUseCase> {
  static const int otpLength = 4;

  late EdfaliConfirmArgs args;

  final otpControllers =
      List.generate(otpLength, (_) => TextEditingController());
  final otpFocusNodes = List.generate(otpLength, (_) => FocusNode());

  final otpError = RxnString();
  final attemptsRemaining = RxnInt();
  final otpSentTo = RxnString();

  /// Seconds left on the gateway's code. Counts down only when the checkout
  /// response told us how long the code lives — the app never invents a
  /// deadline of its own.
  final remainingSeconds = RxnInt();
  Timer? _ticker;

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as EdfaliConfirmArgs;
    otpSentTo.value = args.otpSentTo;
    _startCountdown();
    // The gateway session may have moved on while the app was away, so the
    // screen re-reads it rather than trusting the checkout response alone.
    loadStatus();
  }

  void _startCountdown() {
    final seconds = args.expiresInSeconds;
    if (seconds == null || seconds <= 0) return;

    remainingSeconds.value = seconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = (remainingSeconds.value ?? 0) - 1;
      remainingSeconds.value = left;
      if (left <= 0) {
        timer.cancel();
        // The gateway drops the session at zero; saying so beats letting the
        // customer type a code that can no longer work.
        otpError.value = LocaleKeys.edfaliSessionExpired.tr;
      }
    });
  }

  /// `mm:ss` for the countdown line, or null when there is no deadline.
  String? get countdown {
    final left = remainingSeconds.value;
    if (left == null) return null;
    final safe = left < 0 ? 0 : left;
    final minutes = (safe ~/ 60).toString().padLeft(2, '0');
    final seconds = (safe % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get isExpired =>
      remainingSeconds.value != null && remainingSeconds.value! <= 0;

  bool get isCancelling => getState<dynamic>(kCancelHeldOrder).isLoading;

  /// The order is still PENDING until the code is confirmed, which is exactly
  /// the state `PATCH /orders/{id}/cancel` accepts.
  Future<void> cancelHeldOrder() async {
    if (isCancelling) return;
    await handleState(
      kCancelHeldOrder,
      () => Get.find<CancelOrderUseCase>()
          .call(CancelOrderInput(orderId: args.orderId)),
      onSuccess: (_, __) => _goToCancelled(),
    );
  }

  @override
  void onClose() {
    _ticker?.cancel();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in otpFocusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  String get code => otpControllers.map((c) => c.text).join();

  bool get isConfirming => getState<PaymentStatus>(kConfirmEdfali).isLoading;

  Future<void> loadStatus() async {
    await handleState<EdfaliPaymentStatusEntity>(
      kEdfaliStatus,
      () => Get.find<GetEdfaliPaymentStatusUseCase>().call(args.orderId),
      onSuccess: (status, _) {
        attemptsRemaining.value = status.attemptsRemaining;
        if (status.otpSentTo != null) otpSentTo.value = status.otpSentTo;

        // Already settled while the app was away — nothing left to confirm.
        if (status.status == PaymentStatus.captured) {
          _goToConfirmed();
        }
      },
    );
  }

  void onOtpChanged(int index, String value) {
    if (otpError.value != null) otpError.value = null;

    if (value.length > 1) {
      _distributeCode(value, from: index);
      return;
    }
    if (value.isNotEmpty && index < otpLength - 1) {
      otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    if (otpControllers.every((c) => c.text.isNotEmpty)) confirm();
  }

  /// SMS autofill and paste deliver the whole PIN into a single box — spread it
  /// across the row instead of keeping only the first digit.
  void _distributeCode(String value, {int from = 0}) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    for (var i = from; i < otpLength; i++) {
      final digitIndex = i - from;
      otpControllers[i].text =
          digitIndex < digits.length ? digits[digitIndex] : '';
    }
    final lastFilled = (from + digits.length).clamp(0, otpLength - 1);
    otpFocusNodes[lastFilled].requestFocus();
    if (otpControllers.every((c) => c.text.isNotEmpty)) confirm();
  }

  void clearOtp() {
    for (final controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes.first.requestFocus();
  }

  Future<void> confirm() async {
    if (code.length < otpLength) {
      otpError.value = LocaleKeys.invalidOtp.tr;
      return;
    }

    AppException? failure;

    await handleState<PaymentStatus>(
      kConfirmEdfali,
      () async {
        final result = await useCase.call(
          ConfirmEdfaliInput(orderId: args.orderId, otp: code),
        );
        // Kept before the Result collapses into an AppState, which drops the
        // error code and `attempts_remaining`.
        failure = result.exceptionOrNull;
        return resultToState<PaymentStatus>(result: result);
      },
      onSuccess: (status, _) {
        if (status == PaymentStatus.captured) {
          _goToConfirmed();
        } else if (status == PaymentStatus.pendingManualReview) {
          // The gateway gave no usable answer. Never present this as a failure
          // and never offer to pay again.
          Get.snackbar(
            LocaleKeys.paymentUnderReview.tr,
            LocaleKeys.paymentUnderReviewMessage.tr,
          );
          Get.offAllNamed(Routes.MARKETPLACE_ORDERS);
        }
      },
    );

    final exception = failure;
    if (exception != null) _handleFailure(exception);
  }

  void _handleFailure(AppException exception) {
    clearOtp();

    switch (exception.code) {
      case EdfaliErrorCodes.otpInvalid:
        final remaining = exception.args?['attempts_remaining'];
        if (remaining is num) attemptsRemaining.value = remaining.toInt();
        otpError.value = LocaleKeys.edfaliOtpInvalid.tr;
      case EdfaliErrorCodes.attemptsExceeded:
        otpError.value = LocaleKeys.edfaliAttemptsExceeded.tr;
        _goToCancelled();
      case EdfaliErrorCodes.sessionExpired:
        otpError.value = LocaleKeys.edfaliSessionExpired.tr;
        _goToCancelled();
      case EdfaliErrorCodes.paymentFailed:
        otpError.value = LocaleKeys.edfaliPaymentFailed.tr;
        _goToCancelled();
      default:
        otpError.value = exception.message;
    }
  }

  void _goToConfirmed() {
    Get.offAllNamed(
      Routes.MARKETPLACE_ORDER_CONFIRMED,
      arguments: OrderConfirmedArgs(
        orderId: args.orderId,
        total: args.total,
        paymentMethod: 'Edfali',
      ),
    );
  }

  void _goToCancelled() => Get.offAllNamed(
        Routes.MARKETPLACE_ORDER_CANCELLED,
        arguments: OrderCancelledArgs(
          orderNumber: args.orderNumber,
          total: args.total,
        ),
      );
}
