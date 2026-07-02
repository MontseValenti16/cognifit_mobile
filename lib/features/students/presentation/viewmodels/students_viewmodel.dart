import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/domain/usecases/get_groups_usecase.dart';
import '../../../groups/domain/usecases/create_group_usecase.dart';
import '../../../groups/domain/usecases/delete_group_usecase.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/usecases/get_students_usecase.dart';
import '../../domain/usecases/get_student_by_id_usecase.dart';
import '../../domain/usecases/create_student_usecase.dart';
import '../../domain/usecases/update_student_usecase.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/permanent_delete_student_usecase.dart';
import '../../domain/usecases/activate_student_usecase.dart';

enum StudentsStatus { idle, loading, loaded, mutating, error }

class StudentsViewModel extends ChangeNotifier {
  final GetStudentsUseCase _getStudents;
  final GetStudentByIdUseCase _getStudentById;
  final CreateStudentUseCase _createStudent;
  final UpdateStudentUseCase _updateStudent;
  final DeleteStudentUseCase _deleteStudent;
  final PermanentDeleteStudentUseCase _permanentDeleteStudent;
  final ActivateStudentUseCase _activateStudent;
  final GetGroupsUseCase _getGroups;
  final CreateGroupUseCase _createGroup;
  final DeleteGroupUseCase _deleteGroup;

  StudentsViewModel({
    required GetStudentsUseCase getStudents,
    required GetStudentByIdUseCase getStudentById,
    required CreateStudentUseCase createStudent,
    required UpdateStudentUseCase updateStudent,
    required DeleteStudentUseCase deleteStudent,
    required PermanentDeleteStudentUseCase permanentDeleteStudent,
    required ActivateStudentUseCase activateStudent,
    required GetGroupsUseCase getGroups,
    required CreateGroupUseCase createGroup,
    required DeleteGroupUseCase deleteGroup,
  }) : _getStudents = getStudents,
       _getStudentById = getStudentById,
       _createStudent = createStudent,
       _updateStudent = updateStudent,
       _deleteStudent = deleteStudent,
       _permanentDeleteStudent = permanentDeleteStudent,
       _activateStudent = activateStudent,
       _getGroups = getGroups,
       _createGroup = createGroup,
       _deleteGroup = deleteGroup;

  StudentsStatus _status = StudentsStatus.idle;
  List<StudentEntity> _students = [];
  List<GroupEntity> _groups = [];
  String? _error;
  String _query = '';
  String? _groupFilter;

  StudentsStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == StudentsStatus.loading;
  bool get isMutating => _status == StudentsStatus.mutating;

  List<GroupEntity> get groups => _groups;
  bool get hasGroups => _groups.isNotEmpty;
  String? get groupFilter => _groupFilter;

  List<StudentEntity> get students {
    var list = _groupFilter == null
        ? _students
        : _students.where((s) => s.groupId == _groupFilter).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((s) => s.fullName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int get totalCount => _students.length;
  int get activeCount => _students.where((s) => s.isActive).length;

  /// Default group preselected in the create form (first group, if any).
  GroupEntity? get defaultGroup => _groups.isNotEmpty ? _groups.first : null;

  Future<void> loadStudents() async {
    _status = StudentsStatus.loading;
    _error = null;
    notifyListeners();
    try {
      // Load groups + students together; the create form needs the group list.
      final results = await Future.wait([_getGroups(), _getStudents()]);
      _groups = results[0] as List<GroupEntity>;
      _students = results[1] as List<StudentEntity>;
      _status = StudentsStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = StudentsStatus.error;
    } catch (_) {
      _error = 'No se pudo cargar la lista de alumnos.';
      _status = StudentsStatus.error;
    }
    notifyListeners();
  }

  /// Creates a group and prepends it to the local list so the create-student
  /// form can immediately select it. Returns the new group or null on error.
  Future<GroupEntity?> createGroup(CreateGroupParams params) async {
    _status = StudentsStatus.mutating;
    _error = null;
    notifyListeners();
    try {
      final created = await _createGroup(params);
      _groups = [created, ..._groups];
      _status = StudentsStatus.loaded;
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = StudentsStatus.error;
      notifyListeners();
      return null;
    } catch (_) {
      _error = 'No se pudo crear el grupo.';
      _status = StudentsStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteGroup(String id) async {
    _status = StudentsStatus.mutating;
    _error = null;
    notifyListeners();
    try {
      await _deleteGroup(id);
      _groups = _groups.where((g) => g.id != id).toList();
      if (_groupFilter == id) _groupFilter = null;
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo eliminar el grupo.';
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    }
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  void filterByGroup(String? groupId) {
    _groupFilter = groupId;
    notifyListeners();
  }

  Future<StudentEntity?> getDetail(String id) async {
    try {
      return await _getStudentById(id);
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return null;
    }
  }

  Future<bool> create(CreateStudentParams params) async {
    _status = StudentsStatus.mutating;
    _error = null;
    notifyListeners();
    try {
      final created = await _createStudent(params);
      _students = [..._students, created];
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo crear el alumno.';
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(UpdateStudentParams params) async {
    _status = StudentsStatus.mutating;
    _error = null;
    notifyListeners();
    try {
      final updated = await _updateStudent(params);
      _students = _students
          .map((s) => s.id == updated.id ? updated : s)
          .toList();
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo actualizar el alumno.';
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Soft-delete: desactiva al alumno (is_active=FALSE) sin borrar su
  /// historial clínico, según las HU (BD-02, BD-11). Se mantiene en la
  /// lista local marcado como inactivo en vez de removerse.
  Future<bool> delete(String id) async {
    _status = StudentsStatus.mutating;
    _error = null;
    notifyListeners();
    try {
      await _deleteStudent(id);
      _students = _students
          .map((s) => s.id == id ? s.copyWith(isActive: false) : s)
          .toList();
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo desactivar el alumno.';
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Borrado físico irreversible — elimina al alumno y todos sus datos de la DB.
  Future<bool> permanentDelete(String id) async {
    _status = StudentsStatus.mutating;
    _error = null;
    notifyListeners();
    try {
      await _permanentDeleteStudent(id);
      _students = _students.where((s) => s.id != id).toList();
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo eliminar al alumno.';
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> activate(String id) async {
    _status = StudentsStatus.mutating;
    _error = null;
    notifyListeners();
    try {
      final updated = await _activateStudent(id);
      _students = _students.map((s) => s.id == id ? updated : s).toList();
      _status = StudentsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo reactivar el alumno.';
      _status = StudentsStatus.error;
      notifyListeners();
      return false;
    }
  }
}
