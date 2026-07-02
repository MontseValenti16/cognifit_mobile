import '../repositories/group_repository.dart';

class DeleteGroupUseCase {
  final GroupRepository repository;
  const DeleteGroupUseCase(this.repository);
  Future<void> call(String id) => repository.deleteGroup(id);
}
