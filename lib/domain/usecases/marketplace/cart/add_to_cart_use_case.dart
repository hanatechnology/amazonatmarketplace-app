import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/entities/marketplace/cart_item_entity.dart';
import 'package:marketplace/data/repositories/cart_repository.dart';

class AddToCartInput {
  final String productId;
  final int quantity;

  AddToCartInput({
    required this.productId,
    required this.quantity,
  });
}

class AddToCartUseCase
    extends BaseUseCase<AddToCartInput, CartItemEntity, CartRepository> {
  AddToCartUseCase(super.repository);

  @override
  Future<AppState<CartItemEntity>> call(AddToCartInput input) async {
    final result =
        await repository.addToCart(input.productId, input.quantity);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
