import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/entities/marketplace/notification_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/get_notifications_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/get_unread_count_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/mark_all_notifications_read_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/mark_notification_read_use_case.dart';

/// Read-state filter shown as chips above the list.
enum NotificationReadFilter {
  all,
  unread,
  read;

  /// Value sent as the `is_read` query param. null = no filter.
  bool? get queryValue => switch (this) {
        NotificationReadFilter.all => null,
        NotificationReadFilter.unread => false,
        NotificationReadFilter.read => true,
      };
}

class NotificationsController extends BaseStateController<GetNotificationsUseCase>
    with WidgetsBindingObserver {
  // ── Operation keys ────────────────────────────────────────
  static const String kNotifications = 'notifications';
  static const String kUnreadCount = 'notifications_unread_count';
  static const String kMarkAllRead = 'notifications_mark_all_read';

  static const int kPageSize = 10;

  // ── Local reactive state ──────────────────────────────────
  final filter = NotificationReadFilter.all.obs;
  final hasMore = false.obs;
  final isLoadingMore = false.obs;
  final markingReadIds = <String>{}.obs;

  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadNotifications();
    loadUnreadCount();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// The web client refetches on window focus; the mobile equivalent is
  /// refreshing when the app returns to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshNotifications();
    }
  }

  // ── Loading ───────────────────────────────────────────────

  Future<void> loadNotifications() async {
    _page = 1;
    await _fetchPage(append: false);
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
    await loadUnreadCount();
  }

  /// Appends the next page. No-op while a page is in flight or the list is done.
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page += 1;
    await _fetchPage(append: true);
    isLoadingMore.value = false;
  }

  Future<void> _fetchPage({required bool append}) async {
    await handlePaginationState<NotificationEntity>(
      kNotifications,
      () async {
        final state = await useCase.call(
          PaginationInput(
            page: _page,
            limit: kPageSize,
            filters: filter.value.queryValue,
          ),
        );
        return state.when(
          onInitial: () => const AppStateInitial<List<NotificationEntity>>(),
          onLoading: () => const AppStateLoading<List<NotificationEntity>>(),
          onSuccess: (paged, message) {
            hasMore.value = paged.hasMore;
            _page = paged.currentPage;
            return AppStateSuccess(paged.items, message: message);
          },
          onError: (message, code) {
            // Roll the cursor back so a retry re-requests the failed page.
            if (append && _page > 1) _page -= 1;
            return AppStateError<List<NotificationEntity>>(message, code: code);
          },
        );
      },
      append: append,
    );
  }

  Future<void> loadUnreadCount() async {
    await handleState<int>(
      kUnreadCount,
      () => Get.find<GetUnreadCountUseCase>().execute(),
    );
  }

  // ── Filtering ─────────────────────────────────────────────

  void changeFilter(NotificationReadFilter next) {
    if (filter.value == next) return;
    filter.value = next;
    loadNotifications();
  }

  // ── Mutations ─────────────────────────────────────────────

  /// Marks one notification read and patches it in place, so the list keeps its
  /// scroll position instead of reloading.
  Future<void> markAsRead(NotificationEntity notification) async {
    if (notification.isRead || markingReadIds.contains(notification.id)) return;

    markingReadIds.add(notification.id);
    final state =
        await Get.find<MarkNotificationReadUseCase>().call(notification.id);
    markingReadIds.remove(notification.id);

    if (state is! AppStateSuccess<NotificationEntity>) return;

    _replaceInList(state.data);
    _decrementUnreadCount();

    // The unread filter no longer matches this row — drop it.
    if (filter.value == NotificationReadFilter.unread) {
      _removeFromList(notification.id);
    }
  }

  Future<void> markAllAsRead() async {
    await handleState<int>(
      kMarkAllRead,
      () => Get.find<MarkAllNotificationsReadUseCase>().execute(),
      onSuccess: (_, __) => refreshNotifications(),
    );
  }

  // ── Navigation ────────────────────────────────────────────

  /// Tapping a row marks it read, then navigates if it has a customer-facing
  /// target. Refunds carry a refund id rather than an order id, so they land on
  /// the order list — same as the web client.
  Future<void> onNotificationTap(NotificationEntity notification) async {
    await markAsRead(notification);

    switch (notification.referenceType) {
      case NotificationReferenceType.order:
        if (notification.referenceId != null) {
          Get.toNamed(
            Routes.MARKETPLACE_ORDER_DETAILS,
            arguments: notification.referenceId,
          );
        } else {
          Get.toNamed(Routes.MARKETPLACE_ORDERS);
        }
      case NotificationReferenceType.refund:
        Get.toNamed(Routes.MARKETPLACE_ORDERS);
      default:
        break;
    }
  }

  // ── Derived state ─────────────────────────────────────────

  int get unreadCount => getOperationData<int>(kUnreadCount) ?? 0;

  bool get isMarkingAllRead => getState<int>(kMarkAllRead).isLoading;

  bool isMarkingRead(String id) => markingReadIds.contains(id);

  // ── Internals ─────────────────────────────────────────────

  List<NotificationEntity> get _currentList =>
      getOperationData<List<NotificationEntity>>(kNotifications) ?? const [];

  void _replaceInList(NotificationEntity updated) {
    final list = _currentList;
    final index = list.indexWhere((n) => n.id == updated.id);
    if (index == -1) return;
    final next = [...list]..[index] = updated;
    stateFor<List<NotificationEntity>>(kNotifications).value =
        AppStateSuccess(next);
  }

  void _removeFromList(String id) {
    final next = _currentList.where((n) => n.id != id).toList();
    stateFor<List<NotificationEntity>>(kNotifications).value =
        AppStateSuccess(next);
  }

  void _decrementUnreadCount() {
    final current = unreadCount;
    if (current <= 0) return;
    stateFor<int>(kUnreadCount).value = AppStateSuccess(current - 1);
  }
}
