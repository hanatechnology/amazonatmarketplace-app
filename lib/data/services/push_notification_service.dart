import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../domain/usecases/marketplace/notification/clear_device_token_use_case.dart';
import '../../domain/usecases/marketplace/notification/register_device_token_use_case.dart';
import '../../presentation/controllers/marketplace/notification_badge_controller.dart';
import 'storage_service.dart';

/// Handles a push that arrives while the app is terminated or backgrounded.
///
/// Runs in its own isolate with no access to the app's GetX bindings, so it must
/// stay side-effect free — the system already renders the notification, and the
/// payload is picked up again from `getInitialMessage` when the user taps it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Owns the FCM lifecycle: permission, token registration, and tap routing.
///
/// Registration is deliberately separate from [init]: a token may only be sent
/// once the customer is authenticated, because `POST /device-token` binds it to
/// the caller's JWT.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  bool _initialised = false;

  /// Last token seen, so a refresh that reports the same value is not re-sent.
  String? _registeredToken;

  /// Called once at startup, before the first frame.
  ///
  /// Failure here is swallowed: push is an enhancement, and a misconfigured or
  /// unreachable Firebase must not stop the app from opening.
  Future<void> init() async {
    if (_initialised) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      _initialised = true;
    } catch (error) {
      debugPrint('Push notifications unavailable: $error');
    }
  }

  /// Asks for permission and sends the token to the API. Call after login, and
  /// on startup for a customer whose session was restored.
  Future<void> registerForCurrentUser() async {
    if (!_initialised) return;

    final token = await StorageService.instance.getToken();
    if (token == null || token.isEmpty) return;

    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      // iOS hands out an FCM token only once APNs has registered the device;
      // asking too early returns null rather than throwing.
      final fcmToken = await _messaging.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      await _sendToken(fcmToken);
    } catch (error) {
      debugPrint('Push registration failed: $error');
    }
  }

  /// Clears the token server-side. Best-effort — a failure must never trap the
  /// customer in a signed-in state.
  Future<void> unregister() async {
    _registeredToken = null;
    try {
      if (Get.isRegistered<ClearDeviceTokenUseCase>()) {
        await Get.find<ClearDeviceTokenUseCase>().call();
      }
      if (_initialised) await _messaging.deleteToken();
    } catch (error) {
      debugPrint('Push unregister failed: $error');
    }
  }

  /// Routes the notification the app was launched from, if any. Called once the
  /// first route is on screen so navigation has somewhere to go.
  Future<void> handleLaunchMessage() async {
    if (!_initialised) return;
    final message = await _messaging.getInitialMessage();
    if (message != null) _onMessageOpened(message);
  }

  // ── Internals ─────────────────────────────────────────────

  Future<void> _sendToken(String fcmToken) async {
    if (fcmToken == _registeredToken) return;
    if (!Get.isRegistered<RegisterDeviceTokenUseCase>()) return;

    final result = await Get.find<RegisterDeviceTokenUseCase>().call(fcmToken);
    result.fold(
      onSuccess: (_) => _registeredToken = fcmToken,
      onFailure: (error) =>
          debugPrint('Device token rejected: ${error.message}'),
    );
  }

  Future<void> _onTokenRefresh(String fcmToken) async {
    final token = await StorageService.instance.getToken();
    if (token == null || token.isEmpty) return;
    await _sendToken(fcmToken);
  }

  /// A push that lands while the app is open is not rendered by the system, so
  /// the badge is refreshed instead of showing a tray notification.
  void _onForegroundMessage(RemoteMessage message) {
    _refreshBadge();
  }

  /// Mirrors the in-app tap routing: refunds carry a refund id rather than an
  /// order id, so they land on the order list.
  void _onMessageOpened(RemoteMessage message) {
    _refreshBadge();

    final data = message.data;
    final referenceType = data['reference_type'] as String?;
    final referenceId = data['reference_id'] as String?;

    switch (referenceType) {
      case 'order':
        if (referenceId != null && referenceId.isNotEmpty) {
          Get.toNamed(
            Routes.MARKETPLACE_ORDER_DETAILS,
            arguments: referenceId,
          );
        } else {
          Get.toNamed(Routes.MARKETPLACE_ORDERS);
        }
      case 'refund':
        Get.toNamed(Routes.MARKETPLACE_ORDERS);
      default:
        Get.toNamed(Routes.MARKETPLACE_NOTIFICATIONS);
    }
  }

  void _refreshBadge() {
    // Guarded: the badge controller only exists once the main shell is built.
    if (!Get.isRegistered<NotificationBadgeController>()) return;
    Get.find<NotificationBadgeController>().loadUnreadCount();
  }
}
