import '../entities/group_entity.dart';

abstract class GroupRepository {
  Future<List<GroupEntity>> getGroups();
  Future<GroupEntity> createGroup(CreateGroupParams params);
  Future<void> deleteGroup(String id);
}
