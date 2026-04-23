import 'package:marketplace/data/repositories/local_cart_repository.dart';

/// Updates the quantity of a cart item. Quantity is clamped 1–99 in the repo.
class UpdateLocalCartQuantityUseCase {
  final LocalCartRepository _repo;
  UpdateLocalCartQuantityUseCase(this._repo);

  Future<void> call(String productId, int quantity) =>
      _repo.updateQuantity(productId, quantity);
}
