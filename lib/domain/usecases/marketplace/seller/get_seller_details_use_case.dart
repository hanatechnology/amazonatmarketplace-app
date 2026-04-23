import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';
import 'package:marketplace/data/repositories/seller_repository.dart';

class GetSellerDetailsUseCase
    extends BaseUseCase<String, SellerEntity, SellerRepository> {
  GetSellerDetailsUseCase(super.repository);

  @override
  Future<AppState<SellerEntity>> call(String sellerId) async {
    final result = await repository.getSellerById(sellerId);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
