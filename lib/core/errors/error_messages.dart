import 'package:get/get.dart';

import '../localization/locale_keys.dart';
import 'exceptions.dart';

/// Turns a failure into text a customer can read, in the active language.
///
/// The backend's `message` is written for developers and is English-only, so it
/// is never shown. The machine-readable half — the business `code`, or the
/// exception type when there is no code — is what gets translated instead.
///
/// Add a case here whenever the backend gains a code the customer should be
/// told about by name; anything unmapped falls back to the message for its
/// exception type, which is always safe to show.
extension AppExceptionMessage on AppException {
  String get localizedMessage {
    final byCode = _codeMessages[code];
    if (byCode != null) return byCode.tr;

    return switch (this) {
      NetworkException() => LocaleKeys.errorNoConnection.tr,
      TimeoutException() => LocaleKeys.errorTimeout.tr,
      UnauthorizedException() => LocaleKeys.errorSessionExpired.tr,
      ForbiddenException() => LocaleKeys.errorForbidden.tr,
      NotFoundException() => LocaleKeys.errorNotFound.tr,
      RateLimitException() => LocaleKeys.errorRateLimited.tr,
      ValidationException() => _firstFieldMessage ?? LocaleKeys.errorBadRequest.tr,
      BadRequestException() => LocaleKeys.errorBadRequest.tr,
      ConflictException() => LocaleKeys.errorBadRequest.tr,
      ServerException() => LocaleKeys.errorServer.tr,
      _ => LocaleKeys.errorUnexpected.tr,
    };
  }

  /// Message for [field]'s first reported failure, or null when the backend
  /// blamed no field.
  String? fieldMessage(String field) {
    final code = fieldCode(field);
    if (code == null) return null;
    return validationMessage(code, field: field);
  }

  String? get _firstFieldMessage {
    final entry = fieldErrors?.entries.firstOrNull;
    if (entry == null) return null;
    final code = entry.value.firstOrNull;
    if (code == null) return null;
    return validationMessage(code, field: entry.key);
  }
}

/// Business codes the customer should be told about by name.
const Map<String, String> _codeMessages = {
  'account_deactivated': LocaleKeys.errorAccountDeactivated,
  'account_not_found': LocaleKeys.errorAccountNotFound,
  'address_not_found': LocaleKeys.errorAddressNotFound,
  'edfali_account_not_found': LocaleKeys.errorEdfaliAccountNotFound,
  'edfali_otp_invalid': LocaleKeys.errorEdfaliOtpInvalid,
  'edfali_payment_failed': LocaleKeys.errorEdfaliPaymentFailed,
  'edfali_payment_not_found': LocaleKeys.errorNotFound,
  'edfali_session_expired': LocaleKeys.errorEdfaliSessionExpired,
  'payout_method_invalid': LocaleKeys.errorPayoutMethodInvalid,
  'refund_active_exists': LocaleKeys.errorRefundActiveExists,
  'refund_items_required': LocaleKeys.errorRefundItemsRequired,
  'refund_item_invalid': LocaleKeys.errorRefundItemInvalid,
};

/// Translated text for one field failure.
///
/// [code] is the class-validator constraint name the backend reports in
/// `errors: { field: [{ code }] }` — `isUnique`, `isEmail`, `isNotEmpty`, and so
/// on. `isUnique` reads differently per field, so [field] narrows it.
String validationMessage(String code, {String? field}) {
  switch (code) {
    case 'isNotEmpty':
    case 'isDefined':
    case 'isString':
    case 'arrayNotEmpty':
      return LocaleKeys.fieldRequired.tr;
    case 'isEmail':
      return LocaleKeys.fieldInvalidEmail.tr;
    case 'isUnique':
      return switch (field) {
        'email' => LocaleKeys.fieldEmailTaken.tr,
        'phone' || 'phone_number' => LocaleKeys.fieldPhoneTaken.tr,
        _ => LocaleKeys.fieldInvalid.tr,
      };
    case 'minLength':
    case 'min':
      return LocaleKeys.fieldTooShort.tr;
    case 'maxLength':
    case 'max':
      return LocaleKeys.fieldTooLong.tr;
    default:
      return LocaleKeys.fieldInvalid.tr;
  }
}
