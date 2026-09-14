import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/seller_repository.dart';
import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import '../../../../core/errors/error_messages.dart';

/// Loads one page of vendor stores. `input.filters` carries the search text.
class GetSellersUseCase
    extends PaginationUseCase<SellerEntity, SellerRepository> {
  GetSellersUseCase(super.repository);

  @override
  Future<AppState<PaginatedResult<SellerEntity>>> call(
    PaginationInput input,
  ) async {
    final result = await repository.getSellers(
      page: input.page,
      limit: input.limit,
      search: input.filters as String?,
    );

    return result.fold(
      onSuccess: (page) => AppStateSuccess(
        PaginatedResult<SellerEntity>(
          items: page.items.map((model) => model.toEntity()).toList(),
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          totalItems: page.totalItems,
        ),
      ),
      onFailure: (exception) => AppStateError(exception.localizedMessage),
    );
  }
}
