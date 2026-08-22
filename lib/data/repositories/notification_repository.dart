import 'package:marketplace/core/bases/base_paginated_response.dart';
import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/notification_model.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class NotificationRepository extends BaseRepository<ApiService> {
  NotificationRepository(super.service);

  /// Paginated notification log for the signed-in customer.
  /// [isRead] null = all, false = unread only, true = read only.
  ///
  /// Sorting matches the web client (`sent_at desc`) rather than the spec
  /// default of `created_at` — `sent_at` is the field actually present on the
  /// payload.
  Future<Result<PaginatedResult<NotificationModel>>> getNotifications({
    int page = 1,
    int limit = 10,
    bool? isRead,
  }) {
    return get(
      '/notifications',
      (json) {
        final response = BasePaginatedResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
        );
        return PaginatedResult<NotificationModel>(
          items: response.data,
          currentPage: response.page,
          totalPages: response.totalPages,
          totalItems: response.total,
        );
      },
      queryParams: {
        'page': page,
        'limit': limit,
        'sortBy': 'sent_at',
        'sortDirection': 'desc',
        if (isRead != null) 'is_read': isRead,
      },
    );
  }

  /// Number of unread notifications. Response is `{ unread: n }`.
  Future<Result<int>> getUnreadCount() {
    return get(
      '/notifications/unread-count',
      (json) => BaseResponse.fromJson(
        json as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['unread'] as int? ?? 0,
      ).data,
    );
  }

  Future<Result<NotificationModel>> getNotificationById(String id) {
    return get(
      '/notifications/$id',
      (json) => BaseResponse.fromJson(
        json as Map<String, dynamic>,
        (data) => NotificationModel.fromJson(data as Map<String, dynamic>),
      ).data,
    );
  }

  Future<Result<NotificationModel>> markAsRead(String id) {
    return patch(
      '/notifications/$id/read',
      (json) => BaseResponse.fromJson(
        json as Map<String, dynamic>,
        (data) => NotificationModel.fromJson(data as Map<String, dynamic>),
      ).data,
    );
  }

  /// Marks every unread notification as read. Response is `{ updated: n }`.
  Future<Result<int>> markAllAsRead() {
    return patch(
      '/notifications/read-all',
      (json) => BaseResponse.fromJson(
        json as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['updated'] as int? ?? 0,
      ).data,
    );
  }
}
