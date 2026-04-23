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

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      firstName: json['first_name'] != null ? json['first_name'] as String : null,
      lastName: json['last_name'] != null ? json['last_name'] as String : null,
      email: json['email'] != null ? json['email'] as String : null,
      avatarUrl: json['avatar_url'] != null ? json['avatar_url'] as String : null,
      role: json['role'] as String,
      languagePreference: json['language_preference'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
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

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as String,
    );
  }
}
