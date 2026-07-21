import '../entities/institution_entity.dart';

abstract class InstitutionRepository {
  Future<void> register(RegisterInstitutionParams params);
  Future<List<InstitutionEntity>> getPending();
  Future<InstitutionEntity> approve(String institutionId);
  Future<void> reject(String institutionId, {String? reason});
}
