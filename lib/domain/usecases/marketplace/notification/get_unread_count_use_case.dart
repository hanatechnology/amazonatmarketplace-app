import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/notification_repository.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class GetUnreadCountUseCase extends NoInputUseCase<int, NotificationRepository> {
  GetUnreadCountUseCase(super.repository);

  @override
  Future<AppState<int>> call(_) async {
    final result = await repository.getUnreadCount();
    return resultToState(result: result);
  }
}
