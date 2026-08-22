import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/product_repository.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// Loads one page of products. `input.filters` carries the search text.
///
/// Separate from [GetProductsUseCase], which returns a bare list and cannot
/// tell a caller whether more pages exist.
class GetProductsPageUseCase
    extends PaginationUseCase<ProductEntity, ProductRepository> {
  GetProductsPageUseCase(super.repository);

  @override
  Future<AppState<PaginatedResult<ProductEntity>>> call(
    PaginationInput input,
  ) async {
    final result = await repository.getProductsPage(
      page: input.page,
      limit: input.limit,
      search: input.filters as String?,
    );

    return result.fold(
      onSuccess: (page) => AppStateSuccess(
        PaginatedResult<ProductEntity>(
          items: page.items.map((model) => model.toEntity()).toList(),
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          totalItems: page.totalItems,
        ),
      ),
      onFailure: (exception) => AppStateError(exception.message),
    );
  }
}
