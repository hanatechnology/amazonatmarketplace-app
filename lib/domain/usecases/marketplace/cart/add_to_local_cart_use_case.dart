import 'package:marketplace/data/models/marketplace/local_cart_item_model.dart';
import 'package:marketplace/data/repositories/local_cart_repository.dart';
import 'package:marketplace/domain/entities/marketplace/product_entity.dart';

/// Adds a product to the local cart, or increments its quantity if already present.
class AddToLocalCartUseCase {
  final LocalCartRepository _repo;
  AddToLocalCartUseCase(this._repo);

  Future<void> call(ProductEntity product, int quantity) =>
      _repo.addOrUpdate(LocalCartItemModel.fromProduct(product, quantity));
}
