import 'package:marketplace/data/repositories/local_cart_repository.dart';

/// Wipes the entire local cart — called after successful checkout.
class ClearLocalCartUseCase {
  final LocalCartRepository _repo;
  ClearLocalCartUseCase(this._repo);

  Future<void> call() => _repo.clear();
}
