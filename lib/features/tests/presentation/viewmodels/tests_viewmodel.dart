import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/screening_entity.dart';
import '../../domain/entities/test_entity.dart';
import '../../domain/usecases/get_teacher_items_usecase.dart';
import '../../domain/usecases/submit_teacher_results_usecase.dart';
import '../../domain/usecases/get_catalog_usecase.dart';
import '../../domain/usecases/assign_battery_usecase.dart';
import '../../domain/usecases/open_session_usecase.dart';
import '../../../groups/domain/usecases/get_groups_usecase.dart';
import '../../../students/domain/entities/student_entity.dart';

enum TestsStatus { idle, loading, loaded, submitting, error }

/// Orchestrates the real flow documented in API_UI_GUIA section 4:
/// teacher-items -> teacher-results -> catalog -> assignments -> open first session
class TestsViewModel extends ChangeNotifier {
  final GetTeacherItemsUseCase _getTeacherItems;
  final SubmitTeacherResultsUseCase _submitTeacherResults;
  final GetCatalogUseCase _getCatalog;
  final AssignBatteryUseCase _assignBattery;
  final OpenSessionUseCase _openSession;
  final GetGroupsUseCase _getGroups;
  Map<String, int> _gradePorGrupo = {};
  int? _selectedGrade;

  TestsViewModel({
    required GetTeacherItemsUseCase getTeacherItems,
    required SubmitTeacherResultsUseCase submitTeacherResults,
    required GetCatalogUseCase getCatalog,
    required AssignBatteryUseCase assignBattery,
    required OpenSessionUseCase openSession,
    required GetGroupsUseCase getGroups,
  })  : _getTeacherItems = getTeacherItems,
        _submitTeacherResults = submitTeacherResults,
        _getCatalog = getCatalog,
        _assignBattery = assignBattery,
        _openSession = openSession,
        _getGroups = getGroups;

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

  /// Elige el alumno y carga el cuestionario de su ciclo. El grado sale del
  /// grupo del alumno (ver `gradeDesdeGrupo`); si el grupo no está en el mapa,
  /// `grade` va null y el backend devuelve el cuestionario del primer ciclo.
  Future<void> selectStudentAndLoad(StudentEntity student) async {
    _selectedStudentId = student.id;
    _selectedGrade = gradeDesdeGrupo(student.groupId, _gradePorGrupo);
    answers.clear();
    _teacherResult = null;
    _assignmentResult = null;
    _status = TestsStatus.loading;
    notifyListeners();
    try {
      _teacherItems = await _getTeacherItems(grade: _selectedGrade);
      _status = TestsStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = TestsStatus.error;
    } catch (_) {
      _error = 'No se pudo cargar el cuestionario.'; _status = TestsStatus.error;
    }
    notifyListeners();
  }

  Map<String, List<TeacherItemEntity>> get itemsPorCategoria =>
      agruparPorCategoria(_teacherItems);

  Future<void> loadTeacherItemsAndCatalog() async {
    _status = TestsStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final raw = await _getCatalog();
      final seen = <String>{};
      _catalog = raw.where((m) => seen.add(m.moduleCode)).toList();
      // El grado del alumno se resuelve desde su grupo: el backend no lo manda
      // con la lista de alumnos. Se carga el mapa una vez, acá.
      final grupos = await _getGroups();
      _gradePorGrupo = {for (final g in grupos) g.id: g.grade};
      _status = TestsStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = TestsStatus.error;
    } catch (_) {
      _error = 'No se pudo cargar el catálogo.'; _status = TestsStatus.error;
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

  String moduleName(String code) =>
      _catalog.where((m) => m.moduleCode == code).firstOrNull?.name ?? code;

  void reset() {
    answers.clear();
    _selectedStudentId = null;
    _teacherResult = null;
    _assignmentResult = null;
    _status = TestsStatus.loaded;
    notifyListeners();
  }
}

/// Agrupa los ítems del cuestionario por bloque del protocolo, con la historia
/// clínica primero: son las preguntas que pueden explicar la dificultad por
/// otra causa, y el docente debería contestarlas antes de valorar síntomas.
Map<String, List<TeacherItemEntity>> agruparPorCategoria(List<TeacherItemEntity> items) {
  const orden = ['HISTORIA_CLINICA', 'RIESGO', 'DISCREPANCIA'];
  final mapa = <String, List<TeacherItemEntity>>{};
  for (final cat in orden) {
    final delGrupo = items.where((i) => i.categoria == cat).toList();
    if (delGrupo.isNotEmpty) mapa[cat] = delGrupo;
  }
  return mapa;
}

/// El grado de un alumno sale de su grupo, no del alumno: el backend no lo
/// envía en la lista de alumnos y `StudentEntity` solo tiene `groupId`.
/// Devuelve null si el grupo no está en el mapa, para caer al primer ciclo.
int? gradeDesdeGrupo(String groupId, Map<String, int> gradePorGrupo) =>
    gradePorGrupo[groupId];
