import 'package:marketplace/data/repositories/local_cart_repository.dart';

/// Toggles the selection state of a cart item by [productId].
class ToggleLocalCartSelectionUseCase {
  final LocalCartRepository _repo;
  ToggleLocalCartSelectionUseCase(this._repo);

  Future<void> call(String productId) => _repo.toggleSelection(productId);
}
