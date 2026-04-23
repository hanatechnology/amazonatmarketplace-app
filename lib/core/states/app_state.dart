/// Sealed class representing the state of an async operation.
/// Use [when] for pattern-matching all states.
sealed class AppState<T> {
  const AppState();

  /// Pattern-match all states. All handlers are required.
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(T data, String? message) onSuccess,
    required R Function(String message, int? code) onError,
  }) {
    return switch (this) {
      AppStateInitial<T>() => onInitial(),
      AppStateLoading<T>() => onLoading(),
      AppStateSuccess<T>(data: final d, message: final m) =>
        onSuccess(d, m),
      AppStateError<T>(message: final m, code: final c) => onError(m, c),
    };
  }

  /// Pattern-match with optional handlers (others return null).
  R? maybeWhen<R>({
    R Function()? onInitial,
    R Function()? onLoading,
    R Function(T data, String? message)? onSuccess,
    R Function(String message, int? code)? onError,
  }) {
    return when<R?>(
      onInitial: () => onInitial?.call(),
      onLoading: () => onLoading?.call(),
      onSuccess: (d, m) => onSuccess?.call(d, m),
      onError: (m, c) => onError?.call(m, c),
    );
  }

  bool get isInitial => this is AppStateInitial<T>;
  bool get isLoading => this is AppStateLoading<T>;
  bool get isSuccess => this is AppStateSuccess<T>;
  bool get isError => this is AppStateError<T>;

  T? get dataOrNull =>
      this is AppStateSuccess<T> ? (this as AppStateSuccess<T>).data : null;
}

final class AppStateInitial<T> extends AppState<T> {
  const AppStateInitial();
}

final class AppStateLoading<T> extends AppState<T> {
  const AppStateLoading();
}

final class AppStateSuccess<T> extends AppState<T> {
  const AppStateSuccess(this.data, {this.message});
  final T data;
  final String? message;
}

final class AppStateError<T> extends AppState<T> {
  const AppStateError(this.message, {this.code});
  final String message;
  final int? code;
}
