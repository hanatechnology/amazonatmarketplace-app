import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../errors/exceptions.dart';
import '../network/result.dart';

/// Base HTTP service that wraps [DioClient] with error handling.
abstract class BaseService {
  BaseService(this._dioClient);
  final DioClient _dioClient;

  Dio get dio => _dioClient.dio;

  Future<Result<T>> request<T>({
    required String method,
    required String path,
    required T Function(dynamic json) mapper,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final Response response = switch (method.toUpperCase()) {
        'GET' => await dio.get(path, queryParameters: queryParams),
        'POST' =>
          await dio.post(path, data: data, queryParameters: queryParams),
        'PUT' => await dio.put(path, data: data, queryParameters: queryParams),
        'PATCH' => await dio.patch(path, data: data),
        'DELETE' => await dio.delete(path, data: data),
        _ => throw UnexpectedException('Unsupported HTTP method: $method'),
      };
      return Success(mapper(response.data));
    } on DioException catch (e) {
      return Failure(DioClient.handleDioError(e));
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnexpectedException(e.toString()));
    }
  }
}
