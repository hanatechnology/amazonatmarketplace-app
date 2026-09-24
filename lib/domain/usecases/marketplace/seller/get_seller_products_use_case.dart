import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/seller_repository.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import '../../../../core/errors/error_messages.dart';

/// Input for [GetSellerProductsUseCase].
///
/// The store's name rides along because `GET /stores/{id}/products` does not
/// return the vendor block.
class SellerProductsInput {
  const SellerProductsInput({
    required this.sellerId,
    required this.storeName,
    this.page = 1,
    this.limit = 20,
  });

  final String sellerId;
  final String storeName;
  final int page;
  final int limit;
}

class GetSellerProductsUseCase extends BaseUseCase<SellerProductsInput,
    PaginatedResult<ProductEntity>, SellerRepository> {
  GetSellerProductsUseCase(super.repository);

  @override
  Future<AppState<PaginatedResult<ProductEntity>>> call(
    SellerProductsInput input,
  ) async {
    final result = await repository.getSellerProducts(
      input.sellerId,
      page: input.page,
      limit: input.limit,
      storeName: input.storeName,
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
      onFailure: (exception) =>
          AppStateError(exception.localizedMessage, code: exception.httpStatus),
    );
  }
}
