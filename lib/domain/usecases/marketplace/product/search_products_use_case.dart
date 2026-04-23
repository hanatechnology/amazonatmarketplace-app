import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';
import 'package:marketplace/data/repositories/product_repository.dart';

class SearchProductsUseCase
    extends BaseUseCase<String, List<ProductEntity>, ProductRepository> {
  SearchProductsUseCase(super.repository);

  @override
  Future<AppState<List<ProductEntity>>> call(String query) async {
    final result = await repository.searchProducts(query);
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
