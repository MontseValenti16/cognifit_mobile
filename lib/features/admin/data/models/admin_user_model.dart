import '../../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.isActive,
    super.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
    id: json['id'].toString(),
    email: json['email'] as String,
    role: json['role'] as String,
    isActive: json['is_active'] as bool? ?? true,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
  );
}
