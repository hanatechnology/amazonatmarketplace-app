import 'package:marketplace/data/repositories/local_cart_repository.dart';

/// Selects or deselects all cart items at once.
class SetLocalCartSelectAllUseCase {
  final LocalCartRepository _repo;
  SetLocalCartSelectAllUseCase(this._repo);

  Future<void> call(bool selected) => _repo.setSelectAll(selected);
}
