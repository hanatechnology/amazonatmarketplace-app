import 'package:get/get.dart';
import 'package:marketplace/domain/entities/marketplace/notification_entity.dart';

class NotificationModel {
  NotificationModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.type,
    required this.isRead,
    required this.sentAt,
    this.referenceId,
    this.referenceType,
    this.readAt,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String? type;
  final bool isRead;
  final String sentAt;
  final String? referenceId;
  final String? referenceType;
  final String? readAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      titleAr: json['title_ar'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      bodyAr: json['body_ar'] as String? ?? '',
      bodyEn: json['body_en'] as String? ?? '',
      type: json['type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      sentAt: json['sent_at'] as String? ?? '',
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      readAt: json['read_at'] as String?,
    );
  }

  NotificationEntity toEntity() {
    final isArabic = Get.locale?.languageCode == 'ar';
    return NotificationEntity(
      id: id,
      title: _localized(isArabic ? titleAr : titleEn, isArabic ? titleEn : titleAr),
      body: _localized(isArabic ? bodyAr : bodyEn, isArabic ? bodyEn : bodyAr),
      type: NotificationType.fromApi(type),
      referenceType: NotificationReferenceType.fromApi(referenceType),
      isRead: isRead,
      sentAt: DateTime.tryParse(sentAt)?.toLocal() ?? DateTime.now(),
      referenceId: referenceId,
      readAt: readAt == null ? null : DateTime.tryParse(readAt!)?.toLocal(),
    );
  }

  /// Falls back to the other locale so a notification is never blank —
  /// same rule the web client applies.
  static String _localized(String preferred, String fallback) =>
      preferred.isNotEmpty ? preferred : fallback;
}
