import '../../../../core/network/api_client.dart';
import '../../domain/entities/group_entity.dart';
import '../models/group_model.dart';

abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getGroups();
  Future<GroupModel> createGroup(CreateGroupParams params);
}

/// Maps to the /groups resource of the API.
class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final ApiClient client;
  const GroupRemoteDataSourceImpl(this.client);

  @override
  Future<List<GroupModel>> getGroups() async {
    final json = await client.get('/groups');
    return (json as List).map((e) => GroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<GroupModel> createGroup(CreateGroupParams params) async {
    final json = await client.post('/groups', data: GroupModel.createToJson(params));
    return GroupModel.fromJson(json as Map<String, dynamic>);
  }
}
