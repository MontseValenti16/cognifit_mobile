import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../groups/di/groups_providers.dart';
import '../../../groups/domain/usecases/get_groups_usecase.dart';
import '../../../students/di/students_providers.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/domain/usecases/get_students_usecase.dart';
import '../../../tests/di/tests_providers.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tests/domain/usecases/get_teacher_assignments_usecase.dart';
import '../../../tracking/di/tracking_providers.dart';
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

/// Todo el estado ES el resultado agregado de GET /students + GET
/// /tracking/alerts + GET /groups + métricas por grupo + GET
/// /screening/assignments — por eso el AsyncValue envuelve directamente
/// este objeto en vez de un ViewModel con un flag de loading aparte.
class DashboardData {
  final List<StudentEntity> students;
  final List<AlertEntity> alerts;
  final List<GroupRiskSummary> groupSummaries;
  final List<TeacherAssignmentEntity> pendingAssignments;
  final List<TeacherAssignmentEntity> recentCompleted;

  const DashboardData({
    this.students = const [],
    this.alerts = const [],
    this.groupSummaries = const [],
    this.pendingAssignments = const [],
    this.recentCompleted = const [],
  });

  List<StudentEntity> get recentStudents => students.take(5).toList();
  int get totalStudents => students.length;

  /// Antes contaba alertas HIGH sin leer, no el riesgo real: un alumno con
  /// diagnóstico de riesgo alto pero sin alerta generada (o con la alerta ya
  /// leída) no se sumaba aquí, aunque las tarjetas de "Grupos" sí lo
  /// mostraran correctamente — mismo dato, dos números distintos en la
  /// misma pantalla. Ahora suma el mismo highRisk por grupo que ya se ve
  /// abajo, así los dos coinciden siempre.
  int get atRiskCount => groupSummaries.fold(0, (sum, g) => sum + g.highRisk);
  int get mediumRiskCount => groupSummaries.fold(0, (sum, g) => sum + g.mediumRisk);
  int get lowRiskCount => groupSummaries.fold(0, (sum, g) => sum + g.lowRisk);

  Set<String> get _atRiskStudentIds => alerts.where((a) => a.urgency == 'HIGH').map((a) => a.studentId).toSet();
  List<AlertEntity> get unreadAlerts => alerts.where((a) => !a.isRead).toList();
  AlertEntity? get topAlert => unreadAlerts.isEmpty ? null : unreadAlerts.first;

  /// Sigue basado en alertas: es para el badge de la lista de "Alumnos", que
  /// no tiene acceso al riesgo por alumno (getGroupMetrics solo trae el
  /// conteo agregado del grupo, no qué alumno específico es cada uno).
  bool isStudentAtRisk(String studentId) => _atRiskStudentIds.contains(studentId);

  DashboardData copyWith({
    List<StudentEntity>? students,
    List<AlertEntity>? alerts,
    List<GroupRiskSummary>? groupSummaries,
    List<TeacherAssignmentEntity>? pendingAssignments,
    List<TeacherAssignmentEntity>? recentCompleted,
  }) {
    return DashboardData(
      students: students ?? this.students,
      alerts: alerts ?? this.alerts,
      groupSummaries: groupSummaries ?? this.groupSummaries,
      pendingAssignments: pendingAssignments ?? this.pendingAssignments,
      recentCompleted: recentCompleted ?? this.recentCompleted,
    );
  }
}

class DashboardNotifier extends Notifier<AsyncValue<DashboardData>> {
  late GetStudentsUseCase _getStudents;
  late GetAlertsUseCase _getAlerts;
  late GetGroupsUseCase _getGroups;
  late GetGroupMetricsUseCase _getGroupMetrics;
  late GetTeacherAssignmentsUseCase _getTeacherAssignments;

  @override
  AsyncValue<DashboardData> build() {
    _getStudents = GetStudentsUseCase(ref.watch(studentRepositoryProvider));
    _getAlerts = GetAlertsUseCase(ref.watch(trackingRepositoryProvider));
    _getGroups = GetGroupsUseCase(ref.watch(groupRepositoryProvider));
    _getGroupMetrics = GetGroupMetricsUseCase(ref.watch(trackingRepositoryProvider));
    _getTeacherAssignments = GetTeacherAssignmentsUseCase(ref.watch(screeningRepositoryProvider));
    return const AsyncValue.loading();
  }

  /// Cada sub-carga falla en silencio y conserva el valor anterior: un
  /// endpoint caído no debe tumbar todo el dashboard, solo esa sección se
  /// queda con datos viejos hasta el próximo refresh.
  Future<void> loadDashboard() async {
    state = const AsyncValue.loading();
    final prev = state.valueOrNull ?? const DashboardData();
    var students = prev.students;
    var alerts = prev.alerts;
    var groupSummaries = prev.groupSummaries;
    var pendingAssignments = prev.pendingAssignments;
    var recentCompleted = prev.recentCompleted;

    await Future.wait([
      _getStudents().then((v) => students = v).catchError((_) => students),
      _getAlerts(onlyUnread: true).then((v) => alerts = v).catchError((_) => alerts),
      _loadGroupSummaries().then((v) { if (v != null) groupSummaries = v; }),
      _getTeacherAssignments(status: 'PENDING,IN_PROGRESS')
          .then((v) => pendingAssignments = v)
          .catchError((_) => pendingAssignments),
      _getTeacherAssignments(status: 'COMPLETED')
          .then((v) => recentCompleted = v.take(5).toList())
          .catchError((_) => recentCompleted),
    ]);

    state = AsyncValue.data(DashboardData(
      students: students,
      alerts: alerts,
      groupSummaries: groupSummaries,
      pendingAssignments: pendingAssignments,
      recentCompleted: recentCompleted,
    ));
  }

  Future<List<GroupRiskSummary>?> _loadGroupSummaries() async {
    try {
      final groups = await _getGroups();
      if (groups.isEmpty) return null;
      final metrics = await Future.wait(groups.map((g) => _getGroupMetrics(g.id)));
      return List.generate(groups.length, (i) => GroupRiskSummary(
        groupId: groups[i].id,
        displayName: groups[i].displayName,
        totalStudents: metrics[i].totalStudents,
        highRisk: metrics[i].highRisk,
        mediumRisk: metrics[i].mediumRisk,
        lowRisk: metrics[i].lowRisk,
      ));
    } catch (_) {
      return null;
    }
  }

  void dismissTopAlert() {
    final current = state.valueOrNull;
    final top = current?.topAlert;
    if (current == null || top == null) return;
    state = AsyncValue.data(current.copyWith(alerts: current.alerts.where((a) => a.id != top.id).toList()));
  }
}

final dashboardViewModelProvider = NotifierProvider<DashboardNotifier, AsyncValue<DashboardData>>(DashboardNotifier.new);
