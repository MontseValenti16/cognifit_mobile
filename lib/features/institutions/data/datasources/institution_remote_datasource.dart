import '../../../../core/network/api_client.dart';
import '../../domain/entities/institution_entity.dart';
import '../models/institution_model.dart';

abstract class InstitutionRemoteDataSource {
  Future<void> register(RegisterInstitutionParams params);
  Future<List<InstitutionModel>> getPending();
  Future<InstitutionModel> approve(String institutionId);
  Future<void> reject(String institutionId, {String? reason});
}

class InstitutionRemoteDataSourceImpl implements InstitutionRemoteDataSource {
  final ApiClient client;
  const InstitutionRemoteDataSourceImpl(this.client);

  @override
  Future<void> register(RegisterInstitutionParams params) async {
    await client.post('/institutions/register', data: {
      'school_name': params.schoolName,
      if (params.cct != null && params.cct!.isNotEmpty) 'cct': params.cct,
      'state': params.state,
      if (params.municipality != null && params.municipality!.isNotEmpty) 'municipality': params.municipality,
      'admin_email': params.adminEmail,
      'admin_password': params.adminPassword,
    });
  }

  @override
  Future<List<InstitutionModel>> getPending() async {
    final json = await client.get('/institutions/pending');
    return (json as List).map((e) => InstitutionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<InstitutionModel> approve(String institutionId) async {
    final json = await client.post('/institutions/$institutionId/approve');
    return InstitutionModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> reject(String institutionId, {String? reason}) async {
    await client.post('/institutions/$institutionId/reject', data: {'reason': reason});
  }
}
