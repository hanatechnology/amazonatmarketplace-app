import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/get_unread_count_use_case.dart';

/// Backs the unread badge on the home header. Deliberately lighter than
/// [NotificationsController]: it only ever fetches the count, never the list.
class NotificationBadgeController
    extends BaseStateController<GetUnreadCountUseCase>
    with WidgetsBindingObserver {
  static const String kUnreadCount = 'badge_unread_count';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadUnreadCount();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadUnreadCount();
    }
  }

  Future<void> loadUnreadCount() async {
    await handleState<int>(kUnreadCount, () => useCase.execute());
  }

  int get unreadCount => getOperationData<int>(kUnreadCount) ?? 0;

  /// Push a count that another screen already learned — marking a notification
  /// read on the notifications page, for one. Without this the header badge
  /// keeps the number it fetched on init until the app is resumed.
  void setUnreadCount(int value) {
    stateFor<int>(kUnreadCount).value = AppStateSuccess(value < 0 ? 0 : value);
  }

  /// Every surface that shows the count reads it from here, so they cannot
  /// drift apart.
  static void publish(int value) {
    if (!Get.isRegistered<NotificationBadgeController>()) return;
    Get.find<NotificationBadgeController>().setUnreadCount(value);
  }
}
