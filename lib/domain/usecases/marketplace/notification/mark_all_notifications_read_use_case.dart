import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/notification_repository.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// Returns the number of notifications the server flipped to read.
class MarkAllNotificationsReadUseCase
    extends NoInputUseCase<int, NotificationRepository> {
  MarkAllNotificationsReadUseCase(super.repository);

  @override
  Future<AppState<int>> call(_) async {
    final result = await repository.markAllAsRead();
    return resultToState(result: result);
  }
}
