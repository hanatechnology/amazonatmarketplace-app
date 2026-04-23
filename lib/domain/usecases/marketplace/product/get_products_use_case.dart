import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';
import 'package:marketplace/data/repositories/product_repository.dart';

class GetProductsUseCase
    extends NoInputUseCase<List<ProductEntity>, ProductRepository> {
  GetProductsUseCase(super.repository);

  @override
  Future<AppState<List<ProductEntity>>> call(_) async {
    final result = await repository.getProducts();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
