import '../repositories/admin_repository.dart';

class GetStudentsForPickerUseCase {
  final AdminRepository repository;
  const GetStudentsForPickerUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() => repository.getStudentsForPicker();
}
