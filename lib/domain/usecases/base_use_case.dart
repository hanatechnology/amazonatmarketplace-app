import '../../core/states/app_state.dart';
import '../../core/network/result.dart';
import '../../data/services/api_service.dart';

/// Input for paginated requests.
class PaginationInput<F> {
  const PaginationInput({
    this.page = 1,
    this.limit = 20,
    this.filters,
  });

  final int page;
  final int limit;
  final F? filters;
}

/// Wrapper for paginated results.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  bool get hasMore => currentPage < totalPages;

  PaginatedResult<T> appendPage(PaginatedResult<T> next) {
    return PaginatedResult(
      items: [...items, ...next.items],
      currentPage: next.currentPage,
      totalPages: next.totalPages,
      totalItems: next.totalItems,
    );
  }
}

/// Base use case with injectable repository.
/// [Input]  — input type
/// [Output] — output type
/// [R]      — repository type
abstract class BaseUseCase<Input, Output, R> {
  BaseUseCase(this.repository);
  final R repository;

  /// Execute the use case.
  Future<AppState<Output>> call(Input input);

  /// Convert a [Result<DTO>] → [AppState<Output>] with entity mapping.
  AppState<Output> resultToStateWithMapping<DTO>({
    required Result<DTO> result,
    required Output Function(DTO dto) mapper,
    String? successMessage,
  }) =>
      result.fold(
        onSuccess: (dto) =>
            AppStateSuccess(mapper(dto), message: successMessage),
        onFailure: (e) => AppStateError(e.message),
      );

  /// Convert a [Result<Output>] → [AppState<Output>] directly.
  AppState<Output> resultToState({
    required Result<Output> result,
    String? successMessage,
  }) =>
      result.fold(
        onSuccess: (data) =>
            AppStateSuccess(data, message: successMessage),
        onFailure: (e) => AppStateError(e.message),
      );

  /// Convert a [Result<List<DTO>>] → [AppState<List<Output>>].
  AppState<List<Output>> resultToListState<DTO>({
    required Result<List<DTO>> result,
    required Output Function(DTO dto) mapper,
  }) =>
      result.fold(
        onSuccess: (list) => AppStateSuccess(list.map(mapper).toList()),
        onFailure: (e) => AppStateError(e.message),
      );

  /// Convert a paginated result.
  AppState<PaginatedResult<Output>> resultToPaginatedState<DTO>({
    required Result<PaginatedResult<DTO>> result,
    required Output Function(DTO dto) mapper,
  }) =>
      result.fold(
        onSuccess: (paginated) => AppStateSuccess(PaginatedResult(
          items: paginated.items.map(mapper).toList(),
          currentPage: paginated.currentPage,
          totalPages: paginated.totalPages,
          totalItems: paginated.totalItems,
        )),
        onFailure: (e) => AppStateError(e.message),
      );
}

/// Use case with no input (Unit input).
abstract class NoInputUseCase<Output, R> extends BaseUseCase<void, Output, R> {
  NoInputUseCase(super.repository);

  Future<AppState<Output>> execute() => call(null);
}

/// Use case that returns void on success.
abstract class VoidUseCase<Input, R> extends BaseUseCase<Input, void, R> {
  VoidUseCase(super.repository);
}

/// Specialization for paginated lists.
abstract class PaginationUseCase<Output, R>
    extends BaseUseCase<PaginationInput, PaginatedResult<Output>, R> {
  PaginationUseCase(super.repository);
}
