import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class CreateGroupUseCase {
  final GroupRepository repository;
  const CreateGroupUseCase(this.repository);
  Future<GroupEntity> call(CreateGroupParams params) => repository.createGroup(params);
}
