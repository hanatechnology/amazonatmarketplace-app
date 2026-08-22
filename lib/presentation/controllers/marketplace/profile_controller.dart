import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/localization/locale_controller.dart';
import 'package:marketplace/core/network/dio_client.dart';
import 'package:marketplace/data/models/marketplace/auth_user_model.dart';
import 'package:marketplace/data/services/storage_service.dart';
import 'package:marketplace/data/services/push_notification_service.dart';
import 'package:marketplace/presentation/controllers/marketplace/auth_controller.dart';

/// Account tab.
///
/// There is no `GET /me` in the contract — the customer record is only ever
/// returned by `POST /auth/verify-otp` — so the profile is read from the copy
/// cached at login rather than refetched.
class ProfileController extends GetxController {
  final user = Rxn<AuthUserModel>();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  void loadUserProfile() {
    user.value = AuthController.readCachedUser();
  }

  void refreshProfile() => loadUserProfile();

  // ── Derived display values ────────────────────────────────

  String get displayName {
    final current = user.value;
    if (current == null) return '';
    final parts = [current.firstName, current.lastName]
        .whereType<String>()
        .where((part) => part.isNotEmpty);
    return parts.join(' ');
  }

  String get phone => user.value?.phone ?? '';

  String get email => user.value?.email ?? '';

  /// First letter of the name, for the avatar placeholder.
  String get initial {
    final name = displayName;
    return name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
  }

  // ── Actions ───────────────────────────────────────────────

  void goToOrders() => Get.toNamed(Routes.MARKETPLACE_ORDERS);

  void goToAddresses() => Get.toNamed(Routes.MARKETPLACE_ADDRESSES);

  void goToNotifications() => Get.toNamed(Routes.MARKETPLACE_NOTIFICATIONS);

  void goToHelp() => Get.toNamed(Routes.MARKETPLACE_HELP);

  void toggleLanguage() => Get.find<LocaleController>().toggleLocale();

  /// Drops the JWT and the cached customer, then sends the user back to login.
  /// The in-memory token on [DioClient] is cleared too, so a request already
  /// being built cannot go out authenticated.
  Future<void> logout() async {
    // The device must stop receiving this customer's pushes. Best-effort: a
    // failure here cannot be allowed to trap them in a signed-in state.
    await PushNotificationService.instance.unregister();

    await StorageService.instance.deleteToken();
    StorageService.instance.remove(AuthController.userStorageKey);
    Get.find<DioClient>().updateToken(null);
    user.value = null;
    Get.offAllNamed(Routes.MARKETPLACE_LOGIN);
  }
}
