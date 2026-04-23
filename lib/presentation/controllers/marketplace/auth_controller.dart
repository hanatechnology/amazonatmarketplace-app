import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/network/dio_client.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/models/marketplace/auth_user_model.dart';
import 'package:marketplace/data/services/storage_service.dart';
import 'package:marketplace/domain/usecases/marketplace/auth/request_otp_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/auth/verify_otp_use_case.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../app/routes/app_routes.dart';

const String kSendOtp   = 'send_otp';
const String kVerifyOtp = 'verify_otp';

class AuthController extends BaseStateController<RequestOtpUseCase> {
  late final VerifyOtpUseCase _verifyOtp;

  // ── Phone Entry ────────────────────────────────────────
  final phoneController = TextEditingController();
  final phoneFocusNode  = FocusNode();
  final phoneError      = RxnString();

  // ── OTP ────────────────────────────────────────────────
  final otpControllers  = List.generate(4, (_) => TextEditingController());
  final otpFocusNodes   = List.generate(4, (_) => FocusNode());
  final otpError        = RxnString();
  final isResendEnabled = false.obs;
  final resendCountdown = 60.obs;
  Timer? _resendTimer;

  // ── State ──────────────────────────────────────────────
  final phoneNumber = ''.obs;

  /// True while either OTP request or verification is in flight.
  /// Readable reactively inside any [Obx].
  bool get isLoading =>
      stateFor<void>(kSendOtp).value.isLoading ||
      stateFor<AuthResponseModel>(kVerifyOtp).value.isLoading;

  // ── Typed state accessors (for richer UI bindings) ────
  Rx<AppState<void>> get sendOtpState =>
      stateFor<void>(kSendOtp);

  Rx<AppState<AuthResponseModel>> get verifyOtpState =>
      stateFor<AuthResponseModel>(kVerifyOtp);

  // ── Lifecycle ──────────────────────────────────────────

  @override
  void onInit() {
    super.onInit(); // resolves useCase = RequestOtpUseCase via Get.find
    _verifyOtp = Get.find<VerifyOtpUseCase>();
  }

  @override
  void onClose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    for (final c in otpControllers) c.dispose();
    for (final f in otpFocusNodes) f.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  // ── Validation ─────────────────────────────────────────

  bool validatePhone() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = LocaleKeys.requiredField.tr;
      return false;
    }
    if (phone.length < 9 || !RegExp(r'^[0-9+]+$').hasMatch(phone)) {
      phoneError.value = LocaleKeys.invalidPhone.tr;
      return false;
    }
    phoneError.value = null;
    return true;
  }

  bool validateOtp() {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      otpError.value = LocaleKeys.invalidOtp.tr;
      return false;
    }
    otpError.value = null;
    return true;
  }

  // ── Actions ────────────────────────────────────────────

  /// Step 1 — POST auth/request-otp
  Future<void> sendOtp() async {
    if (!validatePhone()) return;
    phoneNumber.value = phoneController.text.trim();

    await handleState<void>(
      kSendOtp,
      () async => resultToState<void>(
        result: await useCase(phoneNumber.value),
      ),
      onSuccess: (_, __) {
        Get.toNamed(Routes.MARKETPLACE_VERIFY);
        _startResendTimer();
      },
      onError: (message, _) => phoneError.value = message,
    );
  }

  /// Step 2 — POST auth/verify-otp
  Future<void> verifyOtp() async {
    if (!validateOtp()) return;
    final otp = otpControllers.map((c) => c.text).join();

    await handleState<AuthResponseModel>(
      kVerifyOtp,
      () async {
        final result = await _verifyOtp(phoneNumber.value, otp);
        // Persist token + inject into the live DioClient so every subsequent
        // request in this session is automatically authenticated.
        if (result case Success(:final data)) {
          await StorageService.instance.saveToken(data.accessToken);
          Get.find<DioClient>().updateToken(data.accessToken);
        }
        return resultToState<AuthResponseModel>(result: result);
      },
      onSuccess: (_, __) => Get.offAllNamed(Routes.MARKETPLACE_MAIN),
      onError: (message, _) => otpError.value = message,
    );
  }

  /// Guest login — skip auth entirely
  void continueAsGuest() => Get.offAllNamed(Routes.MARKETPLACE_MAIN);

  /// Social login: Google
  Future<void> continueWithGoogle() async {
    // TODO: Implement Google Sign-In
    Get.offAllNamed(Routes.MARKETPLACE_MAIN);
  }

  /// Social login: Apple
  Future<void> continueWithApple() async {
    // TODO: Implement Apple Sign-In
    Get.offAllNamed(Routes.MARKETPLACE_MAIN);
  }

  // ── OTP Resend Timer ───────────────────────────────────

  void _startResendTimer() {
    isResendEnabled.value = false;
    resendCountdown.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        isResendEnabled.value = true;
        timer.cancel();
      }
    });
  }

  void resendOtp() {
    if (!isResendEnabled.value) return;
    for (final c in otpControllers) c.clear();
    sendOtp();
  }

  // ── OTP Field Navigation ───────────────────────────────

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    if (otpControllers.every((c) => c.text.isNotEmpty)) {
      verifyOtp();
    }
  }
}
