import 'package:marketplace/data/repositories/local_cart_repository.dart';
import 'package:marketplace/domain/entities/marketplace/local_cart_item_entity.dart';

/// Returns the current cart items from local storage (synchronous).
class GetLocalCartUseCase {
  final LocalCartRepository _repo;
  GetLocalCartUseCase(this._repo);

  List<LocalCartItemEntity> call() =>
      _repo.getItems().map((m) => m.toEntity()).toList();
}
