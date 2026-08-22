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

/// Arguments for the Edfali confirm screen.
class EdfaliConfirmArgs {
  const EdfaliConfirmArgs({
    required this.orderId,
    required this.total,
    this.otpSentTo,
    this.expiresInSeconds,
  });

  final String orderId;
  final double total;
  final String? otpSentTo;
  final int? expiresInSeconds;
}

const String kConfirmEdfali = 'confirmEdfali';
const String kEdfaliStatus = 'edfaliStatus';

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

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as EdfaliConfirmArgs;
    otpSentTo.value = args.otpSentTo;
    // The gateway session may have moved on while the app was away, so the
    // screen re-reads it rather than trusting the checkout response alone.
    loadStatus();
  }

  @override
  void onClose() {
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

  void _goToCancelled() =>
      Get.offAllNamed(Routes.MARKETPLACE_ORDER_CANCELLED);
}
