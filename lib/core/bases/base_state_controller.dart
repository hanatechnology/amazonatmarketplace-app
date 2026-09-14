import 'package:get/get.dart';
import '../states/app_state.dart';
import '../network/result.dart';
import '../errors/exceptions.dart';
import '../errors/error_messages.dart';
import '../localization/locale_keys.dart';

/// Generic base controller with state management helpers.
/// [U] is the primary use case type injected via GetX.
abstract class BaseStateController<U> extends GetxController {
  /// Primary use case — accessible via [useCase].
  late final U useCase;

  /// Map of operation key → reactive AppState.
  final _states = <String, Rx<AppState<dynamic>>>{};

  @override
  void onInit() {
    super.onInit();
    try {
      useCase = Get.find<U>();
    } catch (_) {
      // Use case not registered — subclass should handle
    }
  }

  // ── State accessors ──────────────────────────────────────

  Rx<AppState<T>> _getOrCreate<T>(String key) {
    if (!_states.containsKey(key)) {
      _states[key] = Rx<AppState<T>>(const AppStateInitial());
    }
    return _states[key]! as Rx<AppState<T>>;
  }

  /// Get the reactive state for [key].
  Rx<AppState<T>> stateFor<T>(String key) => _getOrCreate<T>(key);

  /// Get the current value of a state for [key].
  AppState<T> getState<T>(String key) => _getOrCreate<T>(key).value;

  /// Get the success data for [key] (or null).
  T? getOperationData<T>(String key) {
    final state = getState<T>(key);
    return state.dataOrNull;
  }

  // ── State handlers ───────────────────────────────────────

  /// Run a single async operation and update state for [key].
  Future<void> handleState<T>(
    String key,
    Future<AppState<T>> Function() operation, {
    void Function(T data, String? message)? onSuccess,
    void Function(String message, int? code)? onError,
    bool showLoadingOverlay = false,
  }) async {
    _getOrCreate<T>(key).value = const AppStateLoading();

    try {
      final result = await operation();
      _getOrCreate<T>(key).value = result;

      if (result is AppStateSuccess<T>) {
        onSuccess?.call(result.data, result.message);
      } else if (result is AppStateError<T>) {
        onError?.call(result.message, result.code);
        _handleError(result.message);
      }
    } catch (e) {
      // Never surface a raw exception string: it is English-only and written
      // for developers.
      final message =
          e is AppException ? e.localizedMessage : LocaleKeys.errorUnexpected.tr;
      _getOrCreate<T>(key).value = AppStateError(message);
      onError?.call(message, null);
      _handleError(message);
    }
  }

  /// Run multiple operations concurrently and update their states.
  ///
  /// Takes [StateOperation]s rather than a plain map because a
  /// `Map<String, Function>` cannot carry a different type per entry — every
  /// value would be seen as `dynamic`, and the first `_getOrCreate` call would
  /// pin that key's `Rx` to `AppState<dynamic>` for the lifetime of the
  /// controller. Any later typed read then fails an invariant cast. Each
  /// operation carries its own `T` and applies it through a virtual call, so
  /// the type survives.
  Future<void> handleMultipleStates(
    List<StateOperation> operations, {
    void Function()? onAllSuccess,
  }) async {
    for (final op in operations) {
      op.setLoading(this);
    }

    await Future.wait(operations.map((op) => op.run(this)));

    final allSuccess = operations.every(
      (op) => _states[op.key]?.value.isSuccess ?? false,
    );
    if (allSuccess) onAllSuccess?.call();
  }

  /// Handle a paginated result.
  Future<void> handlePaginationState<T>(
    String key,
    Future<AppState<List<T>>> Function() operation, {
    bool append = false,
    void Function(List<T> data)? onSuccess,
  }) async {
    if (!append) {
      _getOrCreate<List<T>>(key).value = const AppStateLoading();
    }

    try {
      final result = await operation();
      if (result is AppStateSuccess<List<T>>) {
        if (append) {
          final existing = getOperationData<List<T>>(key) ?? [];
          _getOrCreate<List<T>>(key).value =
              AppStateSuccess([...existing, ...result.data]);
        } else {
          _getOrCreate<List<T>>(key).value = result;
        }
        onSuccess?.call(result.data);
      } else if (result is AppStateError<List<T>>) {
        _getOrCreate<List<T>>(key).value = result;
        _handleError(result.message);
      }
    } catch (e) {
      // Never surface a raw exception string: it is English-only and written
      // for developers.
      final message =
          e is AppException ? e.localizedMessage : LocaleKeys.errorUnexpected.tr;
      _getOrCreate<List<T>>(key).value = AppStateError(message);
    }
  }

  void _handleError(String message) {
    // Subclasses can override for custom error handling
  }

  // ── Result helpers ───────────────────────────────────────

  /// Convert a [Result<T>] to an [AppState<T>] using a mapper.
  AppState<T> resultToStateWithMapping<R, T>({
    required Result<R> result,
    required T Function(R dto) mapper,
    String? successMessage,
  }) =>
      result.fold(
        onSuccess: (data) => AppStateSuccess(mapper(data), message: successMessage),
        onFailure: (e) => AppStateError(e.localizedMessage),
      );

  /// Convert a [Result<T>] directly to [AppState<T>].
  AppState<T> resultToState<T>({
    required Result<T> result,
    String? successMessage,
  }) =>
      result.fold(
        onSuccess: (data) => AppStateSuccess(data, message: successMessage),
        onFailure: (e) => AppStateError(e.localizedMessage),
      );
}

/// One keyed operation for [BaseStateController.handleMultipleStates].
///
/// Exists to keep `T` attached to its key. The methods are generic over the
/// instance's own `T`, so calling them through a `List<StateOperation>` still
/// creates correctly-typed states.
class StateOperation<T> {
  const StateOperation(this.key, this.operation);

  final String key;
  final Future<AppState<T>> Function() operation;

  void setLoading(BaseStateController controller) =>
      controller.stateFor<T>(key).value = AppStateLoading<T>();

  Future<void> run(BaseStateController controller) async {
    try {
      controller.stateFor<T>(key).value = await operation();
    } catch (e) {
      // Never surface a raw exception string: it is English-only and written
      // for developers.
      final message =
          e is AppException ? e.localizedMessage : LocaleKeys.errorUnexpected.tr;
      controller.stateFor<T>(key).value = AppStateError<T>(message);
    }
  }
}
