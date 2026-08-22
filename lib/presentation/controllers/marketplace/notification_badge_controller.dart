import 'package:flutter/widgets.dart';
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
}
