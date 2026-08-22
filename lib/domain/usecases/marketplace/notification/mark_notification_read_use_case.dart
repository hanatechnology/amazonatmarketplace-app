import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/notification_repository.dart';
import 'package:marketplace/domain/entities/marketplace/notification_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class MarkNotificationReadUseCase extends BaseUseCase<String,
    NotificationEntity, NotificationRepository> {
  MarkNotificationReadUseCase(super.repository);

  @override
  Future<AppState<NotificationEntity>> call(String id) async {
    final result = await repository.markAsRead(id);
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
