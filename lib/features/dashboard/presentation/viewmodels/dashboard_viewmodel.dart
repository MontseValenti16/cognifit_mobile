import 'package:flutter/foundation.dart';
import '../../../groups/domain/usecases/get_groups_usecase.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/domain/usecases/get_students_usecase.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tests/domain/usecases/get_teacher_assignments_usecase.dart';
import '../../../tracking/domain/entities/tracking_entity.dart';
import '../../../tracking/domain/usecases/get_alerts_usecase.dart';
import '../../../tracking/domain/usecases/get_group_metrics_usecase.dart';

class GroupRiskSummary {
  final String groupId;
  final String displayName;
  final int totalStudents;
  final int highRisk;
  final int mediumRisk;
  final int lowRisk;
  const GroupRiskSummary({
    required this.groupId, required this.displayName, required this.totalStudents,
    required this.highRisk, required this.mediumRisk, required this.lowRisk,
  });
}

/// Dashboard composes: GET /students + GET /tracking/alerts + GET /groups + per-group metrics
/// + GET /screening/assignments (pending & recent completed).
class DashboardViewModel extends ChangeNotifier {
  final GetStudentsUseCase _getStudents;
  final GetAlertsUseCase _getAlerts;
  final GetGroupsUseCase _getGroups;
  final GetGroupMetricsUseCase _getGroupMetrics;
  final GetTeacherAssignmentsUseCase _getTeacherAssignments;

  DashboardViewModel({
    required GetStudentsUseCase getStudents,
    required GetAlertsUseCase getAlerts,
    required GetGroupsUseCase getGroups,
    required GetGroupMetricsUseCase getGroupMetrics,
    required GetTeacherAssignmentsUseCase getTeacherAssignments,
  })  : _getStudents = getStudents,
        _getAlerts = getAlerts,
        _getGroups = getGroups,
        _getGroupMetrics = getGroupMetrics,
        _getTeacherAssignments = getTeacherAssignments;

  bool _isLoading = false;
  List<StudentEntity> _students = [];
  List<AlertEntity> _alerts = [];
  List<GroupRiskSummary> _groupSummaries = [];
  List<TeacherAssignmentEntity> _pendingAssignments = [];
  List<TeacherAssignmentEntity> _recentCompleted = [];

  bool get isLoading => _isLoading;
  List<StudentEntity> get students => _students;
  List<StudentEntity> get recentStudents => _students.take(5).toList();
  List<GroupRiskSummary> get groupSummaries => _groupSummaries;
  List<TeacherAssignmentEntity> get pendingAssignments => _pendingAssignments;
  List<TeacherAssignmentEntity> get recentCompleted => _recentCompleted;

  int get totalStudents => _students.length;

  /// Antes contaba alertas HIGH sin leer, no el riesgo real: un alumno con
  /// diagnóstico de riesgo alto pero sin alerta generada (o con la alerta ya
  /// leída) no se sumaba aquí, aunque las tarjetas de "Grupos" sí lo
  /// mostraran correctamente — mismo dato, dos números distintos en la
  /// misma pantalla. Ahora suma el mismo highRisk por grupo que ya se ve
  /// abajo, así los dos coinciden siempre.
  int get atRiskCount => _groupSummaries.fold(0, (sum, g) => sum + g.highRisk);
  int get mediumRiskCount => _groupSummaries.fold(0, (sum, g) => sum + g.mediumRisk);
  int get lowRiskCount => _groupSummaries.fold(0, (sum, g) => sum + g.lowRisk);

  Set<String> get _atRiskStudentIds => _alerts.where((a) => a.urgency == 'HIGH').map((a) => a.studentId).toSet();
  List<AlertEntity> get unreadAlerts => _alerts.where((a) => !a.isRead).toList();
  AlertEntity? get topAlert => unreadAlerts.isEmpty ? null : unreadAlerts.first;

  /// Sigue basado en alertas: es para el badge de la lista de "Alumnos", que
  /// no tiene acceso al riesgo por alumno (getGroupMetrics solo trae el
  /// conteo agregado del grupo, no qué alumno específico es cada uno).
  bool isStudentAtRisk(String studentId) => _atRiskStudentIds.contains(studentId);

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      _getStudents().then((v) => _students = v).catchError((_) => _students = _students),
      _getAlerts(onlyUnread: true).then((v) => _alerts = v).catchError((_) => _alerts = _alerts),
      _loadGroupSummaries(),
      _getTeacherAssignments(status: 'PENDING,IN_PROGRESS')
          .then((v) => _pendingAssignments = v)
          .catchError((_) => _pendingAssignments = _pendingAssignments),
      _getTeacherAssignments(status: 'COMPLETED')
          .then((v) => _recentCompleted = v.take(5).toList())
          .catchError((_) => _recentCompleted = _recentCompleted),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadGroupSummaries() async {
    try {
      final groups = await _getGroups();
      if (groups.isEmpty) return;
      final metrics = await Future.wait(groups.map((g) => _getGroupMetrics(g.id)));
      _groupSummaries = List.generate(groups.length, (i) => GroupRiskSummary(
        groupId: groups[i].id,
        displayName: groups[i].displayName,
        totalStudents: metrics[i].totalStudents,
        highRisk: metrics[i].highRisk,
        mediumRisk: metrics[i].mediumRisk,
        lowRisk: metrics[i].lowRisk,
      ));
    } catch (_) {}
  }

  void dismissTopAlert() {
    if (topAlert == null) return;
    _alerts = _alerts.where((a) => a.id != topAlert!.id).toList();
    notifyListeners();
  }
}
