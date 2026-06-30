import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class GetCatalogUseCase {
  final ScreeningRepository repository;
  const GetCatalogUseCase(this.repository);
  Future<List<ScreeningModuleEntity>> call() => repository.getCatalog();
}
