import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';

class GetCalendarioUseCase {
  final ScreeningRepository repository;
  const GetCalendarioUseCase(this.repository);

  Future<List<CalendarioEntryEntity>> call({bool soloVencidos = true}) =>
      repository.getCalendario(soloVencidos: soloVencidos);
}
