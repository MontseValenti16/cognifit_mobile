import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/screening_entity.dart';
import '../../domain/entities/test_entity.dart';
import '../../domain/usecases/get_teacher_items_usecase.dart';
import '../../domain/usecases/submit_teacher_results_usecase.dart';
import '../../domain/usecases/get_catalog_usecase.dart';
import '../../domain/usecases/assign_battery_usecase.dart';
import '../../domain/usecases/open_session_usecase.dart';

enum TestsStatus { idle, loading, loaded, submitting, error }

/// Orchestrates the real flow documented in API_UI_GUIA section 4:
/// teacher-items -> teacher-results -> catalog -> assignments -> open first session
class TestsViewModel extends ChangeNotifier {
  final GetTeacherItemsUseCase _getTeacherItems;
  final SubmitTeacherResultsUseCase _submitTeacherResults;
  final GetCatalogUseCase _getCatalog;
  final AssignBatteryUseCase _assignBattery;
  final OpenSessionUseCase _openSession;

  TestsViewModel({
    required GetTeacherItemsUseCase getTeacherItems,
    required SubmitTeacherResultsUseCase submitTeacherResults,
    required GetCatalogUseCase getCatalog,
    required AssignBatteryUseCase assignBattery,
    required OpenSessionUseCase openSession,
  })  : _getTeacherItems = getTeacherItems,
        _submitTeacherResults = submitTeacherResults,
        _getCatalog = getCatalog,
        _assignBattery = assignBattery,
        _openSession = openSession;

  TestsStatus _status = TestsStatus.idle;
  String? _error;

  List<TeacherItemEntity> _teacherItems = [];
  List<ScreeningModuleEntity> _catalog = [];
  List<AssignableStudentEntity> _students = [];

  final Map<String, double> answers = {};
  String? _selectedStudentId;
  TeacherResultEntity? _teacherResult;
  AssignmentResultEntity? _assignmentResult;
  TestEntity? _selectedTest;
  bool _isAssigning = false;

  TestsStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == TestsStatus.loading;
  bool get isSubmitting => _status == TestsStatus.submitting;
  bool get isAssigning => _isAssigning;
  List<TeacherItemEntity> get teacherItems => _teacherItems;
  List<ScreeningModuleEntity> get catalog => _catalog;
  List<AssignableStudentEntity> get students => _students;
  TeacherResultEntity? get teacherResult => _teacherResult;
  AssignmentResultEntity? get assignmentResult => _assignmentResult;
  String? get selectedStudentId => _selectedStudentId;
  TestEntity? get selectedTest => _selectedTest;

  bool get questionnaireComplete => answers.length == 8 && _teacherItems.length == 8;

  void selectStudent(String studentId) {
    _selectedStudentId = studentId;
    answers.clear();
    _teacherResult = null;
    _assignmentResult = null;
    notifyListeners();
  }

  Future<void> loadTeacherItemsAndCatalog() async {
    _status = TestsStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _teacherItems = await _getTeacherItems();
      _catalog = await _getCatalog();
      _status = TestsStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = TestsStatus.error;
    } catch (_) {
      _error = 'No se pudo cargar el cuestionario.'; _status = TestsStatus.error;
    }
    notifyListeners();
  }

  void answerQuestion(String itemCode, double value) {
    answers[itemCode] = value;
    notifyListeners();
  }

  Future<bool> submitQuestionnaire() async {
    if (_selectedStudentId == null || !questionnaireComplete) return false;
    _status = TestsStatus.submitting; _error = null; notifyListeners();
    try {
      final list = _teacherItems.map((i) => TeacherAnswer(itemCode: i.itemCode, value: answers[i.itemCode]!)).toList();
      _teacherResult = await _submitTeacherResults(_selectedStudentId!, list);
      _status = TestsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = TestsStatus.error; notifyListeners(); return false;
    } catch (_) {
      _error = 'No se pudo enviar el cuestionario.'; _status = TestsStatus.error; notifyListeners(); return false;
    }
  }

  Future<bool> assignBattery() async {
    if (_selectedStudentId == null || _teacherResult == null) return false;
    _status = TestsStatus.submitting; _error = null; notifyListeners();
    try {
      _assignmentResult = await _assignBattery(_selectedStudentId!, _teacherResult!.score, _teacherResult!.riskFlags);
      _status = TestsStatus.loaded;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = TestsStatus.error; notifyListeners(); return false;
    } catch (_) {
      _error = 'No se pudo asignar la batería.'; _status = TestsStatus.error; notifyListeners(); return false;
    }
  }

  Future<ScreeningSessionEntity?> openFirstSession() async {
    if (_assignmentResult == null || _assignmentResult!.assignments.isEmpty) return null;
    final first = _assignmentResult!.assignments.first;
    try {
      return await _openSession(assignmentId: first.id, moduleCode: first.moduleCode, deviceId: 'flutter-app', appVersion: '1.0.0');
    } on ApiException catch (e) {
      _error = e.userMessage; notifyListeners(); return null;
    }
  }

  String moduleName(String code) => _catalog.firstWhere(
    (m) => m.moduleCode == code,
    orElse: () => ScreeningModuleEntity(moduleNumber: 0, moduleCode: code, name: code, usaTts: false, usaStt: false),
  ).name;

  void reset() {
    answers.clear();
    _selectedStudentId = null;
    _teacherResult = null;
    _assignmentResult = null;
    _status = TestsStatus.loaded;
    notifyListeners();
  }
}
