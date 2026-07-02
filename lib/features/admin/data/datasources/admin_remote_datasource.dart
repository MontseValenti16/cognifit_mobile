import '../../../../core/network/api_client.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../models/admin_user_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminUserModel>> getUsers({bool includeInactive = false});
  Future<AdminUserModel> createUser(CreateUserParams params);
  Future<AdminUserModel> updateUser(UpdateUserParams params);
  Future<AdminUserModel> deactivateUser(String userId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient client;
  const AdminRemoteDataSourceImpl(this.client);

  @override
  Future<List<AdminUserModel>> getUsers({bool includeInactive = false}) async {
    final json = await client.get(
      '/admin/users',
      query: includeInactive ? {'include_inactive': true} : null,
    );
    return (json as List).map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminUserModel> createUser(CreateUserParams params) async {
    final json = await client.post('/admin/users', data: {
      'email': params.email,
      'password': params.password,
      'role': params.role,
    });
    return AdminUserModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<AdminUserModel> updateUser(UpdateUserParams params) async {
    final json = await client.patch('/admin/users/${params.userId}', data: {
      if (params.role != null) 'role': params.role,
      if (params.isActive != null) 'is_active': params.isActive,
    });
    return AdminUserModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<AdminUserModel> deactivateUser(String userId) async {
    final json = await client.delete('/admin/users/$userId');
    return AdminUserModel.fromJson(json as Map<String, dynamic>);
  }
}
