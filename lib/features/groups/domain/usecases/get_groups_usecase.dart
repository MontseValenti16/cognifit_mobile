import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class GetGroupsUseCase {
  final GroupRepository repository;
  const GetGroupsUseCase(this.repository);
  Future<List<GroupEntity>> call() => repository.getGroups();
}
