import 'package:marketplace/domain/entities/marketplace/account_deletion_entity.dart';

/// Wire model for `DELETE /auth/account`.
class AccountDeletionModel {
  const AccountDeletionModel({
    required this.retentionDays,
    this.deletionRequestedAt,
    this.deletionScheduledAt,
  });

  final int retentionDays;
  final String? deletionRequestedAt;
  final String? deletionScheduledAt;

  /// Falls back to 30 only if the field is absent — the request already
  /// succeeded by the time this parses, and a missing number must not turn a
  /// completed deletion into an error the customer would try to repeat.
  factory AccountDeletionModel.fromJson(Map<String, dynamic> json) {
    return AccountDeletionModel(
      retentionDays: (json['retention_days'] as num?)?.toInt() ?? 30,
      deletionRequestedAt: json['deletion_requested_at'] as String?,
      deletionScheduledAt: json['deletion_scheduled_at'] as String?,
    );
  }

  AccountDeletionEntity toEntity() => AccountDeletionEntity(
        requestedAt: _parse(deletionRequestedAt),
        scheduledAt: _parse(deletionScheduledAt),
        retentionDays: retentionDays,
      );

  static DateTime? _parse(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw)?.toLocal();
}
