import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/repositories/device_token_repository.dart';

/// Registers this device for push notifications.
///
/// Nothing calls this yet: the app has no Firebase Messaging dependency and no
/// `google-services.json` / `GoogleService-Info.plist`, so there is no FCM
/// token to hand over. Once those land, call this after login and on every
/// token refresh.
class RegisterDeviceTokenUseCase {
  RegisterDeviceTokenUseCase(this._repository);

  final DeviceTokenRepository _repository;

  Future<Result<void>> call(String fcmToken) =>
      _repository.register(fcmToken);
}
