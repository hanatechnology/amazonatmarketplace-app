import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/services/api_service.dart';

/// Stores the customer's push-notification token server-side.
///
/// The token itself comes from Firebase Cloud Messaging, which this app does
/// not yet bundle — see [RegisterDeviceTokenUseCase] for what is still missing.
class DeviceTokenRepository extends BaseRepository<ApiService> {
  DeviceTokenRepository(super.service);

  /// `POST /device-token`. The token is capped at 500 characters by the DTO.
  Future<Result<void>> register(String fcmToken) {
    return post<void>(
      '/device-token',
      (_) {},
      body: {'fcm_token': fcmToken},
    );
  }

  /// `DELETE /device-token` — called on logout so the device stops receiving
  /// the previous customer's notifications.
  Future<Result<void>> clear() {
    return delete<void>('/device-token', (_) {});
  }
}
