/// Base exception class for the application.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Network connectivity issues.
final class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection']) : super(message);
}

/// Server returned an error response.
final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

/// Request timed out.
final class TimeoutException extends AppException {
  const TimeoutException([String message = 'Request timed out']) : super(message);
}

/// Unauthorized — 401.
final class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized']) : super(message);
}

/// Forbidden — 403.
final class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Access denied']) : super(message);
}

/// Resource not found — 404.
final class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found']) : super(message);
}

/// Conflict — 409.
final class ConflictException extends AppException {
  const ConflictException(super.message);
}

/// Too many requests — 429.
final class RateLimitException extends AppException {
  const RateLimitException([String message = 'Too many requests']) : super(message);
}

/// Validation error — 422.
final class ValidationException extends AppException {
  const ValidationException(super.message, {this.errors});
  final Map<String, List<String>>? errors;
}

/// JSON parsing failed.
final class ParseException extends AppException {
  const ParseException([String message = 'Failed to parse response']) : super(message);
}

/// Local storage error.
final class StorageException extends AppException {
  const StorageException([String message = 'Storage error']) : super(message);
}

/// Authentication state error.
final class AuthException extends AppException {
  const AuthException([String message = 'Authentication error']) : super(message);
}

/// File upload/download error.
final class FileException extends AppException {
  const FileException(super.message);
}

/// Generic unexpected error.
final class UnexpectedException extends AppException {
  const UnexpectedException([String message = 'An unexpected error occurred']) : super(message);
}

/// Bad request — 400.
final class BadRequestException extends AppException {
  const BadRequestException(super.message);
}
