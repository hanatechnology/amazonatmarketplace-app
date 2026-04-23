import '../errors/exceptions.dart';

/// Either-like type that holds either a [Success] or [Failure].
sealed class Result<T> {
  const Result();

  /// Apply [onSuccess] or [onFailure] based on the result type.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException exception) onFailure,
  }) =>
      switch (this) {
        Success<T>(data: final d) => onSuccess(d),
        Failure<T>(exception: final e) => onFailure(e),
      };

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull =>
      this is Success<T> ? (this as Success<T>).data : null;

  AppException? get exceptionOrNull =>
      this is Failure<T> ? (this as Failure<T>).exception : null;
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.exception);
  final AppException exception;
}
