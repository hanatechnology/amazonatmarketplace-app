import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/cart_item_entity.dart';
import 'package:marketplace/data/repositories/cart_repository.dart';

class GetCartUseCase
    extends NoInputUseCase<List<CartItemEntity>, CartRepository> {
  GetCartUseCase(super.repository);

  @override
  Future<AppState<List<CartItemEntity>>> call(_) async {
    final result = await repository.getCartItems();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
