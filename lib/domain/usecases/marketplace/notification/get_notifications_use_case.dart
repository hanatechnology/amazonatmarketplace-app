import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/notification_repository.dart';
import 'package:marketplace/domain/entities/marketplace/notification_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

/// Loads one page of notifications.
/// `input.filters` carries the read filter: null = all, false = unread, true = read.
class GetNotificationsUseCase
    extends PaginationUseCase<NotificationEntity, NotificationRepository> {
  GetNotificationsUseCase(super.repository);

  @override
  Future<AppState<PaginatedResult<NotificationEntity>>> call(
    PaginationInput input,
  ) async {
    final result = await repository.getNotifications(
      page: input.page,
      limit: input.limit,
      isRead: input.filters as bool?,
    );

    // Mapped by hand rather than via `resultToPaginatedState`: that helper is
    // typed for use cases whose `Output` is the item, while a PaginationUseCase
    // already declares `Output` as the page wrapper.
    return result.fold(
      onSuccess: (page) => AppStateSuccess(
        PaginatedResult<NotificationEntity>(
          items: page.items.map((model) => model.toEntity()).toList(),
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          totalItems: page.totalItems,
        ),
      ),
      onFailure: (exception) => AppStateError(exception.message),
    );
  }
}
