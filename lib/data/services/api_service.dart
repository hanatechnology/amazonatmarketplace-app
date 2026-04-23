import '../../core/bases/base_service.dart';
import '../../core/network/result.dart';
import '../../core/network/dio_client.dart';

/// Concrete HTTP service implementing REST operations.
/// Inject a [DioClient] instance (configured with base URL and token).
class ApiService extends BaseService {
  ApiService(super.dioClient);

  /// Convenience factory with default DioClient.
  factory ApiService.create({String? baseUrl, String? token}) =>
      ApiService(DioClient(baseUrl: baseUrl, token: token));

  Future<Result<T>> get<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? queryParams,
  }) =>
      request(
        method: 'GET',
        path: path,
        mapper: mapper,
        queryParams: queryParams,
      );

  Future<Result<T>> post<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? body,
  }) =>
      request(method: 'POST', path: path, mapper: mapper, data: body);

  Future<Result<T>> put<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? body,
  }) =>
      request(method: 'PUT', path: path, mapper: mapper, data: body);

  Future<Result<T>> patch<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? body,
  }) =>
      request(method: 'PATCH', path: path, mapper: mapper, data: body);

  Future<Result<T>> delete<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? body,
  }) =>
      request(method: 'DELETE', path: path, mapper: mapper, data: body);
}
