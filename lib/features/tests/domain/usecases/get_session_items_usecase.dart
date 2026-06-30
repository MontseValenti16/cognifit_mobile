import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class GetSessionItemsUseCase {
  final ScreeningRepository repository;
  const GetSessionItemsUseCase(this.repository);
  Future<SessionItemsResultEntity> call(String sessionId) => repository.getSessionItems(sessionId);
}
