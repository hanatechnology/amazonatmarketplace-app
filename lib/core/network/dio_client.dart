import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Configured Dio HTTP client.
/// Handles common error mapping from DioException to [AppException].
class DioClient {
  DioClient({String? baseUrl, String? token}) : _token = token {
    _dio = Dio(BaseOptions(
      baseUrl:
          baseUrl ?? "https://api.marketplace.amazonatlibya.org/client/api/v1",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Interceptor reads _token via closure — updateToken() is the one source
    // of truth and takes effect on the very next request.
    _dio.interceptors.addAll([
      _AuthInterceptor(() => _token),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[DioClient] $obj'),
      ),
    ]);
  }

  late final Dio _dio;
  String? _token;

  Dio get dio => _dio;

  /// Call this after login/logout. Effective on the next request.
  void updateToken(String? token) => _token = token;

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
        final message =
            _extractMessage(data) ?? error.message ?? 'Server error';
        return switch (statusCode) {
          400 => BadRequestException(message),
          401 => UnauthorizedException(message),
          403 => ForbiddenException(message),
          404 => NotFoundException(message),
          409 => ConflictException(message),
          422 => ValidationException(message),
          429 => RateLimitException(message),
          _ => ServerException(message, statusCode: statusCode),
        };
      default:
        return UnexpectedException(error.message ?? 'Unexpected error');
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['msg']?.toString();
    }
    return data.toString();
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._getToken);
  final String? Function() _getToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
