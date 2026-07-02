import '../repositories/admin_repository.dart';

class LinkParentUseCase {
  final AdminRepository repository;
  const LinkParentUseCase(this.repository);

  Future<void> call(String userId, String studentId) =>
      repository.linkParentToStudent(userId, studentId);
}
