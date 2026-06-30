import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/usecases/get_students_usecase.dart';
import '../../domain/usecases/get_student_by_id_usecase.dart';
import '../../domain/usecases/create_student_usecase.dart';
import '../../domain/usecases/update_student_usecase.dart';
import '../../domain/usecases/delete_student_usecase.dart';

enum StudentsStatus { idle, loading, loaded, mutating, error }

class StudentsViewModel extends ChangeNotifier {
  final GetStudentsUseCase _getStudents;
  final GetStudentByIdUseCase _getStudentById;
  final CreateStudentUseCase _createStudent;
  final UpdateStudentUseCase _updateStudent;
  final DeleteStudentUseCase _deleteStudent;

  StudentsViewModel({
    required GetStudentsUseCase getStudents,
    required GetStudentByIdUseCase getStudentById,
    required CreateStudentUseCase createStudent,
    required UpdateStudentUseCase updateStudent,
    required DeleteStudentUseCase deleteStudent,
  })  : _getStudents = getStudents,
        _getStudentById = getStudentById,
        _createStudent = createStudent,
        _updateStudent = updateStudent,
        _deleteStudent = deleteStudent;

  StudentsStatus _status = StudentsStatus.idle;
  List<StudentEntity> _students = [];
  String? _error;
  String _query = '';

  StudentsStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == StudentsStatus.loading;
  bool get isMutating => _status == StudentsStatus.mutating;

  List<StudentEntity> get students {
    if (_query.isEmpty) return _students;
    final q = _query.toLowerCase();
    return _students.where((s) => s.fullName.toLowerCase().contains(q)).toList();
  }

  int get totalCount => _students.length;
  int get activeCount => _students.where((s) => s.isActive).length;

  Future<void> loadStudents() async {
    _status = StudentsStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _students = await _getStudents();
      _status = StudentsStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = StudentsStatus.error;
    } catch (_) {
      _error = 'No se pudo cargar la lista de alumnos.'; _status = StudentsStatus.error;
    }
    notifyListeners();
  }

  void search(String query) { _query = query; notifyListeners(); }

  Future<StudentEntity?> getDetail(String id) async {
    try {
      return await _getStudentById(id);
    } on ApiException catch (e) {
      _error = e.userMessage; notifyListeners(); return null;
    }
  }

  Future<bool> create(CreateStudentParams params) async {
    _status = StudentsStatus.mutating; _error = null; notifyListeners();
    try {
      final created = await _createStudent(params);
      _students = [..._students, created];
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = StudentsStatus.error; notifyListeners(); return false;
    } catch (_) {
      _error = 'No se pudo crear el alumno.'; _status = StudentsStatus.error; notifyListeners(); return false;
    }
  }

  Future<bool> update(UpdateStudentParams params) async {
    _status = StudentsStatus.mutating; _error = null; notifyListeners();
    try {
      final updated = await _updateStudent(params);
      _students = _students.map((s) => s.id == updated.id ? updated : s).toList();
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = StudentsStatus.error; notifyListeners(); return false;
    } catch (_) {
      _error = 'No se pudo actualizar el alumno.'; _status = StudentsStatus.error; notifyListeners(); return false;
    }
  }

  Future<bool> delete(String id) async {
    _status = StudentsStatus.mutating; _error = null; notifyListeners();
    try {
      await _deleteStudent(id);
      _students = _students.where((s) => s.id != id).toList();
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = StudentsStatus.error; notifyListeners(); return false;
    } catch (_) {
      _error = 'No se pudo eliminar el alumno.'; _status = StudentsStatus.error; notifyListeners(); return false;
    }
  }
}
