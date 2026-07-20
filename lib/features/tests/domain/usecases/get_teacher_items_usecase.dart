import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class GetTeacherItemsUseCase {
  final ScreeningRepository repository;
  const GetTeacherItemsUseCase(this.repository);
  Future<List<TeacherItemEntity>> call({int? grade}) =>
      repository.getTeacherItems(grade: grade);
}
