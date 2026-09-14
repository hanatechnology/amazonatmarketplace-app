import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/get_unread_count_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/order/get_orders_use_case.dart';
import 'package:marketplace/core/localization/locale_controller.dart';
import 'package:marketplace/core/network/dio_client.dart';
import 'package:marketplace/data/models/marketplace/auth_user_model.dart';
import 'package:marketplace/data/services/storage_service.dart';
import 'package:marketplace/data/services/push_notification_service.dart';
import 'package:marketplace/presentation/controllers/marketplace/auth_controller.dart';
import 'package:marketplace/presentation/controllers/marketplace/notification_badge_controller.dart';

/// Account tab.
///
/// There is no `GET /me` in the contract — the customer record is only ever
/// returned by `POST /auth/verify-otp` — so the profile is read from the copy
/// cached at login rather than refetched.
class ProfileController extends GetxController {
  final user = Rxn<AuthUserModel>();

  /// The three counters on the account header. Each is a real call — orders
  /// from the `GET /orders` envelope, addresses from `GET /addresses`, unread
  /// from `GET /notifications/unread-count`. Null means "not loaded yet", which
  /// renders as a dash rather than a zero the customer would read as fact.
  final orderCount = RxnInt();
  final addressCount = RxnInt();
  final unreadCount = RxnInt();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadStats();
  }

  void loadUserProfile() {
    user.value = AuthController.readCachedUser();
  }

  Future<void> refreshProfile() async {
    loadUserProfile();
    await loadStats();
  }

  /// All three are decoration on a screen that works without them, so each
  /// failure is swallowed independently rather than taking the tab down.
  Future<void> loadStats() async {
    await Future.wait([
      _loadOrderCount(),
      _loadAddressCount(),
      _loadUnreadCount(),
    ]);
  }

  Future<void> _loadOrderCount() async {
    final state = await Get.find<GetOrdersUseCase>()
        .call(const PaginationInput(page: 1, limit: 1));
    state.maybeWhen(onSuccess: (page, _) => orderCount.value = page.totalItems);
  }

  Future<void> _loadAddressCount() async {
    final state = await Get.find<GetAddressesUseCase>().execute();
    state.maybeWhen(onSuccess: (list, _) => addressCount.value = list.length);
  }

  Future<void> _loadUnreadCount() async {
    final state = await Get.find<GetUnreadCountUseCase>().execute();
    state.maybeWhen(onSuccess: (count, _) {
      unreadCount.value = count;
      // Keep the header bell on the same number this tab is showing.
      NotificationBadgeController.publish(count);
    });
  }

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

  /// Awaited: reading a notification changes the unread count, and this tab
  /// would otherwise keep the number it loaded on init until a pull-to-refresh.
  Future<void> goToNotifications() async {
    await Get.toNamed(Routes.MARKETPLACE_NOTIFICATIONS);
    await _loadUnreadCount();
  }

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
