import 'package:equatable/equatable.dart';

/// Result of `DELETE /auth/account` — the account is deactivated immediately
/// and erased once [scheduledAt] passes.
///
/// [retentionDays] comes from the server rather than being assumed here: the
/// grace period is the backend's policy, and the confirmation the customer just
/// read has to match what was actually recorded.
class AccountDeletionEntity extends Equatable {
  const AccountDeletionEntity({
    required this.requestedAt,
    required this.scheduledAt,
    required this.retentionDays,
  });

  final DateTime? requestedAt;
  final DateTime? scheduledAt;
  final int retentionDays;

  @override
  List<Object?> get props => [requestedAt, scheduledAt, retentionDays];
}
