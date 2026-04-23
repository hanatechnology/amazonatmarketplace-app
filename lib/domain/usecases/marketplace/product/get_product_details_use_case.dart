import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/product_details_entity.dart';
import 'package:marketplace/data/repositories/product_repository.dart';

class GetProductDetailsUseCase
    extends BaseUseCase<String, ProductDetailsEntity, ProductRepository> {
  GetProductDetailsUseCase(super.repository);

  @override
  Future<AppState<ProductDetailsEntity>> call(String productId) async {
    final result = await repository.getProductById(productId);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
