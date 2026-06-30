import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class SubmitResponsesUseCase {
  final ScreeningRepository repository;
  const SubmitResponsesUseCase(this.repository);
  Future<List<ResponseResultEntity>> call(String sessionId, List<ItemResponseSubmission> responses) =>
      repository.submitResponses(sessionId, responses);
}
