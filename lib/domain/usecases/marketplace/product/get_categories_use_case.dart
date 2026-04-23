import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/category_entity.dart';
import 'package:marketplace/data/repositories/product_repository.dart';

class GetCategoriesUseCase
    extends NoInputUseCase<List<CategoryEntity>, ProductRepository> {
  GetCategoriesUseCase(super.repository);

  @override
  Future<AppState<List<CategoryEntity>>> call(_) async {
    final result = await repository.getCategories();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
