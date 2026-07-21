import '../repositories/institution_repository.dart';

class RejectInstitutionUseCase {
  final InstitutionRepository repository;
  const RejectInstitutionUseCase(this.repository);

  Future<void> call(String institutionId, {String? reason}) =>
      repository.reject(institutionId, reason: reason);
}
