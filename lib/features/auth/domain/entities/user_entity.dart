enum UserRole { superadmin, admin, specialist, teacher, parent, student }

UserRole roleFromString(String s) => switch (s.toUpperCase()) {
  'SUPERADMIN' => UserRole.superadmin,
  'ADMIN' => UserRole.admin,
  'SPECIALIST' => UserRole.specialist,
  'TEACHER' => UserRole.teacher,
  'PARENT' => UserRole.parent,
  'STUDENT' => UserRole.student,
  _ => UserRole.teacher,
};

String roleToString(UserRole r) => switch (r) {
  UserRole.superadmin => 'SUPERADMIN',
  UserRole.admin => 'ADMIN',
  UserRole.specialist => 'SPECIALIST',
  UserRole.teacher => 'TEACHER',
  UserRole.parent => 'PARENT',
  UserRole.student => 'STUDENT',
};

class UserEntity {
  final String id;
  final String email;
  final UserRole role;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
  });
}

class SessionEntity {
  final String accessToken;
  final String refreshToken;
  final int expiresInMinutes;
  const SessionEntity({required this.accessToken, required this.refreshToken, required this.expiresInMinutes});
}
