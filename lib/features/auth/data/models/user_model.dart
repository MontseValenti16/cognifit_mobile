import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email, required super.role, required super.isActive});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    role: roleFromString(json['role'] as String? ?? 'TEACHER'),
    isActive: json['is_active'] as bool? ?? true,
  );
}

class SessionModel extends SessionEntity {
  const SessionModel({required super.accessToken, required super.refreshToken, required super.expiresInMinutes});

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiresInMinutes: json['expires_in_minutes'] as int? ?? 15,
  );
}
