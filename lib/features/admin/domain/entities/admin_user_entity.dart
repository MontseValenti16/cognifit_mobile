class AdminUserEntity {
  final String id;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  const AdminUserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
    this.createdAt,
  });
}

class CreateUserParams {
  final String email;
  final String password;
  final String role;
  const CreateUserParams({required this.email, required this.password, required this.role});
}

class UpdateUserParams {
  final String userId;
  final String? role;
  final bool? isActive;
  const UpdateUserParams({required this.userId, this.role, this.isActive});
}
