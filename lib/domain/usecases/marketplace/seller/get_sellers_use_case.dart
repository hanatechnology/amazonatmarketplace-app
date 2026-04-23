import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';
import 'package:marketplace/data/repositories/seller_repository.dart';

class GetSellersUseCase
    extends NoInputUseCase<List<SellerEntity>, SellerRepository> {
  GetSellersUseCase(super.repository);

  @override
  Future<AppState<List<SellerEntity>>> call(_) async {
    final result = await repository.getSellers();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
