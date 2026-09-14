import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';

/// Configured Dio HTTP client.
/// Handles common error mapping from DioException to [AppException].
class DioClient {
  DioClient({String? baseUrl, String? token}) : _token = token {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Interceptor reads _token via closure — updateToken() is the one source
    // of truth and takes effect on the very next request.
    _dio.interceptors.add(_AuthInterceptor(() => _token, () => _tokenReady));
    // Bodies contain the bearer token and customer data — off in release
    // unless ENABLE_HTTP_LOGS is passed for a QA build.
    if (AppConfig.enableHttpLogs) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DioClient] $obj'),
      ));
    }
  }

  late final Dio _dio;
  String? _token;

  /// Completes once the stored token has been read back from secure storage.
  ///
  /// Hydration is async, so a screen that fires an authed request the instant
  /// it opens — a push-notification tap, a deep link, the first frame after a
  /// cold start — could otherwise beat the token into the client and get a
  /// spurious 401. Requests wait on this instead of racing it.
  Completer<void>? _hydration;

  Future<void>? get _tokenReady =>
      _hydration?.isCompleted ?? true ? null : _hydration!.future;

  Dio get dio => _dio;

  /// Marks the start of token hydration. Requests made from here until
  /// [updateToken] or [finishHydration] runs will wait for it.
  void beginHydration() {
    if (_hydration != null && !_hydration!.isCompleted) return;
    _hydration = Completer<void>();
  }

  /// Releases any requests parked by [beginHydration] without setting a token —
  /// the customer simply is not logged in.
  void finishHydration() {
    if (_hydration != null && !_hydration!.isCompleted) {
      _hydration!.complete();
    }
  }

  /// Call this after login/logout, and when hydration finds a stored token.
  /// Effective on the next request, and releases anything waiting on hydration.
  void updateToken(String? token) {
    _token = token;
    finishHydration();
  }

  /// Map a [DioException] to a typed [AppException].
  static AppException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        final code = _extractCode(data);
        final args = _extractArgs(data);
        final fieldErrors = _extractFieldErrors(data);
        final message =
            _extractMessage(data) ?? error.message ?? 'Server error';

        // A per-field breakdown is a validation failure whatever the status.
        if (fieldErrors != null && fieldErrors.isNotEmpty) {
          return ValidationException(
            message,
            fieldErrors: fieldErrors,
            code: code,
          );
        }

        return switch (statusCode) {
          400 => BadRequestException(message, code: code, args: args),
          401 => UnauthorizedException(message, code: code, args: args),
          403 => ForbiddenException(message),
          404 => NotFoundException(message),
          409 => ConflictException(message, code: code, args: args),
          422 => ValidationException(message, code: code),
          429 => RateLimitException(message, code: code, args: args),
          _ => ServerException(
              message,
              statusCode: statusCode,
              code: code,
              args: args,
            ),
        };
      default:
        return UnexpectedException(error.message ?? 'Unexpected error');
    }
  }

  /// Human-readable message. Never falls back to `data['error']` — that field
  /// holds the discriminator (`'AppError'`, `'ValidationError'`), which would
  /// otherwise be shown to the user verbatim.
  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is! Map) return data.toString();

    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) return message.first.toString();

    return data['msg']?.toString();
  }

  /// Machine-readable business code (`registration_required`, `otp_rate_limited`…).
  static String? _extractCode(dynamic data) {
    if (data is! Map) return null;
    final code = data['code'];
    return code is String && code.isNotEmpty ? code : null;
  }

  static Map<String, dynamic>? _extractArgs(dynamic data) {
    if (data is! Map) return null;
    final args = data['args'];
    return args is Map ? Map<String, dynamic>.from(args) : null;
  }

  /// `{ errors: { field: [{ code, args }] } }` → `{ field: [code] }`.
  static Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is! Map) return null;
    final errors = data['errors'];
    if (errors is! Map) return null;

    final parsed = <String, List<String>>{};
    errors.forEach((field, failures) {
      if (failures is! List) return;
      final codes = failures
          .map((failure) => failure is Map ? failure['code'] : failure)
          .whereType<String>()
          .toList();
      if (codes.isNotEmpty) parsed['$field'] = codes;
    });
    return parsed.isEmpty ? null : parsed;
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._getToken, this._tokenReady);

  final String? Function() _getToken;
  final Future<void>? Function() _tokenReady;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Park the request while the stored token is still being read, so a screen
    // opened straight from a push or a deep link does not 401 on its own token.
    await _tokenReady();

    final token = _getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // The backend picks the Arabic or English SMS template from this header.
    // It matters most on a first signup, where there is no account row yet to
    // read a language preference from.
    options.headers['Accept-Language'] = Get.locale?.languageCode ?? 'en';

    handler.next(options);
  }
}
