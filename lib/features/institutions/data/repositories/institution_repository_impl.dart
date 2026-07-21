import '../../domain/entities/institution_entity.dart';
import '../../domain/repositories/institution_repository.dart';
import '../datasources/institution_remote_datasource.dart';

class InstitutionRepositoryImpl implements InstitutionRepository {
  final InstitutionRemoteDataSource remote;
  const InstitutionRepositoryImpl(this.remote);

  @override
  Future<void> register(RegisterInstitutionParams params) => remote.register(params);

  @override
  Future<List<InstitutionEntity>> getPending() => remote.getPending();

  @override
  Future<InstitutionEntity> approve(String institutionId) => remote.approve(institutionId);

  @override
  Future<void> reject(String institutionId, {String? reason}) =>
      remote.reject(institutionId, reason: reason);
}
