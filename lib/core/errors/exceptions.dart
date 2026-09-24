/// Base exception class for the application.
///
/// The backend's error filter emits three wire shapes, all discriminated by
/// `error`:
///   ValidationError -> { error, message, errors: { field: [{ code, args }] } }
///   AppError        -> { error, code, args?, message }
///   Generic         -> { error, code, message }
///
/// [code] and [args] carry the machine-readable half so callers can branch on
/// a business outcome (`registration_required`, `otp_resend_too_soon`, …)
/// instead of pattern-matching a human string. [fieldErrors] maps a form field
/// to its ordered failure codes.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.args, this.fieldErrors});

  final String message;
  final String? code;
  final Map<String, dynamic>? args;
  final Map<String, List<String>>? fieldErrors;

  /// First failure code reported for [field], if any.
  String? fieldCode(String field) => fieldErrors?[field]?.firstOrNull;

  /// HTTP status this failure came from, when the transport knew one.
  ///
  /// Typed subclasses already encode the status they were built for, so a
  /// caller can branch on a business outcome the contract only expresses as a
  /// status — a coverage 400 from `GET /orders/shipping-fee`, a 404 from a
  /// withdrawn product — without reaching back into the Dio layer.
  int? get httpStatus => switch (this) {
        BadRequestException() => 400,
        UnauthorizedException() => 401,
        ForbiddenException() => 403,
        NotFoundException() => 404,
        ConflictException() => 409,
        RateLimitException() => 429,
        // Carries its own: a per-field breakdown arrives on 400 as well as 422.
        ValidationException(statusCode: final status) => status,
        ServerException(statusCode: final status) => status,
        NetworkException() ||
        TimeoutException() ||
        ParseException() ||
        StorageException() ||
        AuthException() ||
        FileException() ||
        UnexpectedException() =>
          null,
      };

  @override
  String toString() => '$runtimeType: $message${code == null ? '' : ' ($code)'}';
}

/// Network connectivity issues.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Server returned an error response.
final class ServerException extends AppException {
  const ServerException(
    super.message, {
    this.statusCode,
    super.code,
    super.args,
    super.fieldErrors,
  });
  final int? statusCode;
}

/// Request timed out.
final class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

/// Unauthorized — 401.
final class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.code, super.args});
}

/// Forbidden — 403.
final class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Access denied']);
}

/// Resource not found — 404.
final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

/// Conflict — 409.
final class ConflictException extends AppException {
  const ConflictException(super.message, {super.code, super.args});
}

/// Too many requests — 429.
final class RateLimitException extends AppException {
  const RateLimitException(super.message, {super.code, super.args});

  /// Seconds the caller must wait, when the backend supplies it
  /// (`otp_resend_too_soon` carries `args.retry_after_seconds`).
  int? get retryAfterSeconds {
    final value = args?['retry_after_seconds'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}

/// Validation error — 400 / 422 with a per-field breakdown.
final class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.fieldErrors,
    super.code,
    this.statusCode,
  });

  final int? statusCode;
}

/// JSON parsing failed.
final class ParseException extends AppException {
  const ParseException([super.message = 'Failed to parse response']);
}

/// Local storage error.
final class StorageException extends AppException {
  const StorageException([super.message = 'Storage error']);
}

/// Authentication state error.
final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error']);
}

/// File upload/download error.
final class FileException extends AppException {
  const FileException(super.message);
}

/// Generic unexpected error.
final class UnexpectedException extends AppException {
  const UnexpectedException([super.message = 'An unexpected error occurred']);
}

/// Bad request — 400.
final class BadRequestException extends AppException {
  const BadRequestException(super.message, {super.code, super.args});
}
