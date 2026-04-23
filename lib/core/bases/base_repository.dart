import '../network/result.dart';
import '../errors/exceptions.dart';
import '../../data/services/api_service.dart';

/// Base repository that wraps API calls with typed error handling.
/// [S] is the service type (defaults to [ApiService]).
abstract class BaseRepository<S extends ApiService> {
  BaseRepository(this.service);
  final S service;

  /// Wraps a repository operation with safe error handling.
  Future<Result<T>> handleApiCall<T>(Future<Result<T>> Function() call) async {
    try {
      return await call();
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnexpectedException(e.toString()));
    }
  }

  /// GET request helper.
  Future<Result<T>> get<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? queryParams,
  }) =>
      handleApiCall(() => service.get(path, mapper, queryParams: queryParams));

  /// POST request helper.
  Future<Result<T>> post<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? body,
  }) =>
      handleApiCall(() => service.post(path, mapper, body: body));

  /// PUT request helper.
  Future<Result<T>> put<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? body,
  }) =>
      handleApiCall(() => service.put(path, mapper, body: body));

  /// PATCH request helper.
  Future<Result<T>> patch<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? body,
  }) =>
      handleApiCall(() => service.patch(path, mapper, body: body));

  /// DELETE request helper.
  Future<Result<T>> delete<T>(
    String path,
    T Function(dynamic json) mapper, {
    Map<String, dynamic>? body,
  }) =>
      handleApiCall(() => service.delete(path, mapper, body: body));
}
