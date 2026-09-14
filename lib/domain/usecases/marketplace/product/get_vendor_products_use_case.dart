import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/product_repository.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// Input for [GetVendorProductsUseCase].
class VendorProductsInput {
  const VendorProductsInput({
    required this.vendorId,
    this.excludeProductId,
    this.limit = 10,
  });

  final String vendorId;

  /// The product whose page is asking. It is dropped from the result so the
  /// rail never offers the customer the item already on screen.
  final String? excludeProductId;

  final int limit;
}

/// The "more from this store" rail on the product page.
///
/// `GET /products?vendor_id=` is the only way to reach a store's other items
/// from a product — the product payload carries one vendor and no sibling list.
class GetVendorProductsUseCase extends BaseUseCase<VendorProductsInput,
    List<ProductEntity>, ProductRepository> {
  GetVendorProductsUseCase(super.repository);

  @override
  Future<AppState<List<ProductEntity>>> call(VendorProductsInput input) async {
    // One extra row, so excluding the current product cannot shrink the rail
    // below the requested length.
    final result = await repository.getProducts(
      vendorId: input.vendorId,
      limit: input.limit + 1,
    );

    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models
          .map((model) => model.toEntity())
          .where((product) => product.id != input.excludeProductId)
          .take(input.limit)
          .toList(),
    );
  }
}
