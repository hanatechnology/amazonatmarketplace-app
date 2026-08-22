import 'package:equatable/equatable.dart';

/// Category of a notification, as sent by the API.
enum NotificationType {
  orderStatus,
  announcement,
  system,
  unknown;

  static NotificationType fromApi(String? value) => switch (value) {
        'ORDER_STATUS' => NotificationType.orderStatus,
        'ANNOUNCEMENT' => NotificationType.announcement,
        'SYSTEM' => NotificationType.system,
        _ => NotificationType.unknown,
      };
}

/// What a notification points at. Only [order] and [refund] are customer-facing;
/// the rest belong to vendor flows and are not routable from this app.
enum NotificationReferenceType {
  order,
  refund,
  vendorApplication,
  wallet,
  cashout,
  none;

  static NotificationReferenceType fromApi(String? value) => switch (value) {
        'order' => NotificationReferenceType.order,
        'refund' => NotificationReferenceType.refund,
        'vendor_application' => NotificationReferenceType.vendorApplication,
        'wallet' => NotificationReferenceType.wallet,
        'cashout' => NotificationReferenceType.cashout,
        _ => NotificationReferenceType.none,
      };
}

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceType,
    required this.isRead,
    required this.sentAt,
    this.referenceId,
    this.readAt,
  });

  final String id;

  /// Already locale-resolved (see [NotificationModel.toEntity]).
  final String title;

  /// Already locale-resolved (see [NotificationModel.toEntity]).
  final String body;

  final NotificationType type;
  final NotificationReferenceType referenceType;
  final bool isRead;
  final DateTime sentAt;
  final String? referenceId;
  final DateTime? readAt;

  /// Whether tapping this notification should navigate somewhere.
  /// Refund notifications carry a refund id, not an order id, so they land on
  /// the order list rather than a detail screen — matching the web client.
  bool get isRoutable =>
      referenceType == NotificationReferenceType.order ||
      referenceType == NotificationReferenceType.refund;

  NotificationEntity copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      type: type,
      referenceType: referenceType,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt,
      referenceId: referenceId,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        referenceType,
        isRead,
        sentAt,
        referenceId,
        readAt,
      ];
}
