import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remote;
  const GroupRepositoryImpl(this.remote);

  @override
  Future<List<GroupEntity>> getGroups() => remote.getGroups();
  @override
  Future<GroupEntity> createGroup(CreateGroupParams params) => remote.createGroup(params);
}
