import 'package:marketplace/data/repositories/local_cart_repository.dart';

/// Removes an item from the local cart by [productId].
class RemoveFromLocalCartUseCase {
  final LocalCartRepository _repo;
  RemoveFromLocalCartUseCase(this._repo);

  Future<void> call(String productId) => _repo.remove(productId);
}
