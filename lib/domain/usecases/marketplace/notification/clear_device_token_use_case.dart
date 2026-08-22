import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/repositories/device_token_repository.dart';

/// Clears this device's push token. Safe to call even when none was ever
/// registered — the endpoint just has nothing to remove.
class ClearDeviceTokenUseCase {
  ClearDeviceTokenUseCase(this._repository);

  final DeviceTokenRepository _repository;

  Future<Result<void>> call() => _repository.clear();
}
