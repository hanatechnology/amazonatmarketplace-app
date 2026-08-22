import 'package:get/get.dart';
import 'package:marketplace/data/repositories/notification_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/get_notifications_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/get_unread_count_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/mark_all_notifications_read_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/notification/mark_notification_read_use_case.dart';
import 'package:marketplace/presentation/controllers/marketplace/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationRepository(Get.find<ApiService>()),
        fenix: true);

    Get.lazyPut(() => GetNotificationsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetUnreadCountUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => MarkNotificationReadUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => MarkAllNotificationsReadUseCase(Get.find()), fenix: true);

    Get.lazyPut(() => NotificationsController(), fenix: true);
  }
}
