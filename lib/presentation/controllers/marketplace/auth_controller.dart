import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/errors/exceptions.dart';
import 'package:marketplace/core/network/dio_client.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/core/utils/phone_utils.dart';
import 'package:marketplace/data/models/marketplace/auth_user_model.dart';
import 'package:marketplace/data/services/push_notification_service.dart';
import 'package:marketplace/data/services/session_service.dart';
import 'package:marketplace/data/services/storage_service.dart';
import 'package:marketplace/domain/usecases/marketplace/auth/request_otp_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/auth/verify_otp_use_case.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/errors/error_messages.dart';
import 'package:marketplace/app/routes/app_router.dart';

const String kSendOtp = 'send_otp';
const String kVerifyOtp = 'verify_otp';

/// Business error codes emitted by the auth endpoints.
abstract class AuthErrorCodes {
  AuthErrorCodes._();

  /// The phone has no account yet — resend with first_name + email to register.
  static const String registrationRequired = 'registration_required';

  /// A code went out less than a minute ago; `args.retry_after_seconds` says when.
  static const String resendTooSoon = 'otp_resend_too_soon';

  /// Hourly/daily cap for this number reached.
  static const String rateLimited = 'otp_rate_limited';

  /// Five wrong codes — the OTP was destroyed and must be requested again.
  static const String tooManyAttempts = 'otp_too_many_attempts';
}

class AuthController extends BaseStateController<RequestOtpUseCase> {
  late final VerifyOtpUseCase _verifyOtp;

  /// SharedPreferences key holding the customer cached at login.
  /// Read by the profile tab and cleared on logout.
  static const String userStorageKey = 'auth_user';

  // ── Phone Entry ────────────────────────────────────────
  final phoneController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final phoneError = RxnString();

  // ── Registration (revealed on `registration_required`) ─
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final firstNameError = RxnString();
  final emailError = RxnString();

  /// True once the API has told us this phone needs registering. The login form
  /// swaps to the sign-up variant instead of pushing a separate screen.
  final needsRegistration = false.obs;

  // ── OTP ────────────────────────────────────────────────
  /// One field for the whole code, not one per digit — see [OtpCodeField].
  /// Six fields mean five focus hops, and every hop drops and re-opens the iOS
  /// keyboard.
  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();
  final otpError = RxnString();
  final isResendEnabled = false.obs;
  final resendCountdown = 60.obs;
  Timer? _resendTimer;

  /// The API accepts 4–6 digits; the backend issues 6.
  static const int otpLength = 6;
  static const int _defaultResendSeconds = 60;

  // ── State ──────────────────────────────────────────────

  /// Always E.164 (`+218…`) — the same value must reach both auth calls.
  final phoneNumber = ''.obs;

  /// True while either OTP request or verification is in flight.
  /// Readable reactively inside any [Obx].
  bool get isLoading =>
      stateFor<void>(kSendOtp).value.isLoading ||
      stateFor<AuthResponseModel>(kVerifyOtp).value.isLoading;

  // ── Typed state accessors (for richer UI bindings) ────
  Rx<AppState<void>> get sendOtpState => stateFor<void>(kSendOtp);

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
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    otpController.dispose();
    otpFocusNode.dispose();
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
    if (!PhoneUtils.isValid(phone)) {
      phoneError.value = LocaleKeys.invalidPhone.tr;
      return false;
    }
    phoneError.value = null;
    return true;
  }

  /// Only the fields the API demands for registration: first name and email.
  /// Last name is optional and saved when present.
  bool validateRegistration() {
    var isValid = true;

    if (firstNameController.text.trim().isEmpty) {
      firstNameError.value = LocaleKeys.requiredField.tr;
      isValid = false;
    } else {
      firstNameError.value = null;
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = LocaleKeys.requiredField.tr;
      isValid = false;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = LocaleKeys.invalidEmail.tr;
      isValid = false;
    } else {
      emailError.value = null;
    }

    return isValid;
  }

  bool validateOtp() {
    final otp = otpController.text;
    if (otp.length < otpLength) {
      otpError.value = LocaleKeys.invalidOtp.tr;
      return false;
    }
    otpError.value = null;
    return true;
  }

  // ── Actions ────────────────────────────────────────────

  /// Step 1 — POST auth/request-otp.
  ///
  /// Sends phone only on the first attempt. If the API answers
  /// `registration_required` the sign-up fields are revealed and the next
  /// submit repeats the call with the profile data attached.
  Future<void> sendOtp() async {
    if (!validatePhone()) return;
    if (needsRegistration.value && !validateRegistration()) return;

    phoneNumber.value = PhoneUtils.normalize(phoneController.text);

    await handleState<void>(
      kSendOtp,
      () async {
        final result = await useCase(
          phoneNumber.value,
          firstName:
              needsRegistration.value ? firstNameController.text.trim() : null,
          lastName:
              needsRegistration.value ? lastNameController.text.trim() : null,
          email: needsRegistration.value ? emailController.text.trim() : null,
        );
        _captureException(kSendOtp, result);
        return resultToState<void>(result: result);
      },
      onSuccess: (_, __) {
        // The account exists from here on, so a later edit of the phone number
        // starts again from the plain sign-in form.
        final wasRegistering = needsRegistration.value;
        needsRegistration.value = false;
        _startResendTimer();
        if (wasRegistering) {
          // Replace the create-account screen: going "back" from the OTP should
          // land on the phone step, not on a form that is already submitted.
          Get.offNamed(Routes.MARKETPLACE_VERIFY);
        } else {
          AppRouter.toNamed(Routes.MARKETPLACE_VERIFY);
        }
      },
    );

    final state = sendOtpState.value;
    if (state is AppStateError<void>) {
      _handleRequestOtpError(state);
    }
  }

  /// Step 2 — POST auth/verify-otp.
  Future<void> verifyOtp() async {
    if (!validateOtp()) return;
    final otp = otpController.text;

    await handleState<AuthResponseModel>(
      kVerifyOtp,
      () async {
        final result = await _verifyOtp(phoneNumber.value, otp);
        _captureException(kVerifyOtp, result);
        // Persist the session and inject the token into the live DioClient so
        // every subsequent request in this session is authenticated.
        if (result case Success(:final data)) {
          await _persistSession(data);
        }
        return resultToState<AuthResponseModel>(result: result);
      },
      onSuccess: (_, __) {
        _resendTimer?.cancel();
        // The device token is bound to the caller's JWT, so it can only be sent
        // once a session exists.
        PushNotificationService.instance.registerForCurrentUser();
        // A guard may have interrupted a journey to get here. Rebuild the shell
        // first — the tabs have to come back with a session behind them — then
        // push the screen the customer was actually after, the same way the web
        // client honours `/login?redirect=…`.
        final pending = SessionService.to.takeIntendedRoute();
        SessionService.to.markSignedIn();
        Get.offAllNamed(Routes.MARKETPLACE_MAIN);
        if (pending != null) {
          AppRouter.toNamed<void>(pending.route, arguments: pending.arguments);
        }
      },
      onError: (message, _) => otpError.value = message,
    );

    final state = verifyOtpState.value;
    if (state is AppStateError<AuthResponseModel>) {
      _handleVerifyOtpError(state);
    }
  }

  // Guest browsing lives on the welcome screen, not here — see
  // [SessionService]. Social sign-in is deliberately absent: no OAuth endpoint
  // exists in the contract at all.

  // ── Error handling ─────────────────────────────────────

  void _handleRequestOtpError(AppStateError<void> state) {
    final exception = _lastException(kSendOtp);

    switch (exception?.code) {
      // Not an account yet — reveal the sign-up fields and let the user retry.
      case AuthErrorCodes.registrationRequired:
        needsRegistration.value = true;
        phoneError.value = null;
        // `request-otp` will not send a code for an unknown number until it has
        // first_name and email, so the details are collected BEFORE the OTP —
        // a post-verification "complete your profile" step is impossible here.
        if (Get.currentRoute != Routes.MARKETPLACE_COMPLETE_DETAILS) {
          AppRouter.toNamed(Routes.MARKETPLACE_COMPLETE_DETAILS);
        }
        return;

      // A code is still live; keep the user on the OTP screen and count down
      // whatever the backend says is left.
      case AuthErrorCodes.resendTooSoon:
        final retryAfter = exception is RateLimitException
            ? exception.retryAfterSeconds
            : null;
        _startResendTimer(seconds: retryAfter ?? _defaultResendSeconds);
        if (Get.currentRoute != Routes.MARKETPLACE_VERIFY) {
          AppRouter.toNamed(Routes.MARKETPLACE_VERIFY);
        }
        return;

      case AuthErrorCodes.rateLimited:
        phoneError.value = LocaleKeys.otpRateLimited.tr;
        return;
    }

    // Field-level failures land on the input they belong to, with the message
    // translated from the backend's constraint code — its own `message` is
    // English-only.
    if (exception is ValidationException) {
      final email = exception.fieldMessage('email');
      if (email != null) {
        emailError.value = email;
        needsRegistration.value = true;
        return;
      }
      final firstName = exception.fieldMessage('first_name');
      if (firstName != null) {
        firstNameError.value = firstName;
        needsRegistration.value = true;
        return;
      }
    }

    phoneError.value = exception?.localizedMessage ?? state.message;
  }

  void _handleVerifyOtpError(AppStateError<AuthResponseModel> state) {
    final exception = _lastException(kVerifyOtp);

    // The OTP is gone after too many wrong tries — sending the user back to the
    // phone step is the only way forward, so don't leave them on a dead screen.
    if (exception?.code == AuthErrorCodes.tooManyAttempts) {
      clearOtp();
      _resendTimer?.cancel();
      isResendEnabled.value = true;
      otpError.value = LocaleKeys.otpTooManyAttempts.tr;
      return;
    }

    otpError.value = exception?.localizedMessage ?? state.message;
  }

  final Map<String, AppException?> _lastExceptions = {};

  /// [AppState] keeps only the message, so the typed exception is stashed at the
  /// repository boundary — that is where the business `code` still exists.
  void _captureException(String key, Result<dynamic> result) {
    _lastExceptions[key] = result.exceptionOrNull;
  }

  /// The exception behind the last failure for [key], when there was one.
  AppException? _lastException(String key) => _lastExceptions[key];

  // ── Session ────────────────────────────────────────────

  Future<void> _persistSession(AuthResponseModel data) async {
    await StorageService.instance.saveToken(data.accessToken);
    Get.find<DioClient>().updateToken(data.accessToken);

    // Cached so the profile screen has a user before its first network call.
    StorageService.instance.write(
      userStorageKey,
      jsonEncode({
        'id': data.user.id,
        'phone': data.user.phone,
        'first_name': data.user.firstName,
        'last_name': data.user.lastName,
        'email': data.user.email,
        'avatar_url': data.user.avatarUrl,
        'role': data.user.role,
      }),
    );
  }

  /// Cached user from the last successful login, if any.
  static AuthUserModel? readCachedUser() {
    final raw = StorageService.instance.read<String>(userStorageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthUserModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  // ── OTP Resend Timer ───────────────────────────────────

  void _startResendTimer({int seconds = _defaultResendSeconds}) {
    isResendEnabled.value = false;
    resendCountdown.value = seconds;
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
    clearOtp();
    sendOtp();
  }

  void clearOtp() {
    otpController.clear();
    otpError.value = null;
    otpFocusNode.requestFocus();
  }

  /// Back to the phone step from the OTP screen, keeping whatever was typed.
  void editPhone() {
    _resendTimer?.cancel();
    clearOtp();
    Get.back();
  }

  // ── OTP Field Navigation ───────────────────────────────

  /// The field holds the whole code, so there is no focus to move and no
  /// paste to spread across boxes: a full-length value — typed, pasted or
  /// delivered by SMS autofill — submits itself.
  void onOtpChanged(String value) {
    if (otpError.value != null) otpError.value = null;
    if (value.length == otpLength) verifyOtp();
  }
}
