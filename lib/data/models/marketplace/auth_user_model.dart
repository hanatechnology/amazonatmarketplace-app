import 'package:marketplace/domain/entities/marketplace/auth_user_entity.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
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

  /// Tolerant on purpose: the verify-otp payload documented in the OpenAPI spec
  /// carries only id / phone / names / email / role, so anything beyond that
  /// must be optional or a successful login would throw while parsing.
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      phone: json['phone'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'CUSTOMER',
      languagePreference: json['language_preference'] as String? ?? 'ar',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  AuthUserEntity toEntity() {
    return AuthUserEntity(
      id: id,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatarUrl: avatarUrl,
      role: role,
      languagePreference: languagePreference,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

class AuthResponseModel {
  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.expiresIn,
  });

  final AuthUserModel user;
  final String accessToken;
  final String expiresIn;

  /// `expires_in` is a duration string (`"7d"`) in the API spec but the web
  /// client types it as a number, so accept either rather than gamble on a cast.
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      expiresIn: '${json['expires_in'] ?? ''}',
    );
  }
}
