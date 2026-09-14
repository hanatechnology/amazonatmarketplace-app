import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/product_repository.dart';
import 'package:marketplace/domain/entities/marketplace/category_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// The nested category hierarchy.
///
/// Browse reads the tree rather than the flat list because subcategory counts
/// and the subcategory rail exist nowhere else in the contract.
class GetCategoryTreeUseCase
    extends NoInputUseCase<List<CategoryEntity>, ProductRepository> {
  GetCategoryTreeUseCase(super.repository);

  @override
  Future<AppState<List<CategoryEntity>>> call(_) async {
    final result = await repository.getCategoryTree();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
