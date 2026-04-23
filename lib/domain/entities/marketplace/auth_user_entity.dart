class AuthUserEntity {
  const AuthUserEntity({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.languagePreference,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;
  final String role;
  final String languagePreference;
  final bool isActive;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();
}
