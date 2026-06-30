import 'package:flutter/foundation.dart';
import '../../../groups/domain/usecases/get_groups_usecase.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/domain/usecases/get_students_usecase.dart';
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

/// Dashboard composes: GET /students + GET /tracking/alerts + GET /groups + per-group metrics.
class DashboardViewModel extends ChangeNotifier {
  final GetStudentsUseCase _getStudents;
  final GetAlertsUseCase _getAlerts;
  final GetGroupsUseCase _getGroups;
  final GetGroupMetricsUseCase _getGroupMetrics;

  DashboardViewModel({
    required GetStudentsUseCase getStudents,
    required GetAlertsUseCase getAlerts,
    required GetGroupsUseCase getGroups,
    required GetGroupMetricsUseCase getGroupMetrics,
  })  : _getStudents = getStudents,
        _getAlerts = getAlerts,
        _getGroups = getGroups,
        _getGroupMetrics = getGroupMetrics;

  bool _isLoading = false;
  List<StudentEntity> _students = [];
  List<AlertEntity> _alerts = [];
  List<GroupRiskSummary> _groupSummaries = [];

  bool get isLoading => _isLoading;
  List<StudentEntity> get students => _students;
  List<StudentEntity> get recentStudents => _students.take(5).toList();
  List<GroupRiskSummary> get groupSummaries => _groupSummaries;

  int get totalStudents => _students.length;
  Set<String> get _atRiskStudentIds => _alerts.where((a) => a.urgency == 'HIGH').map((a) => a.studentId).toSet();
  int get atRiskCount => _atRiskStudentIds.length;
  List<AlertEntity> get unreadAlerts => _alerts.where((a) => !a.isRead).toList();
  AlertEntity? get topAlert => unreadAlerts.isEmpty ? null : unreadAlerts.first;

  bool isStudentAtRisk(String studentId) => _atRiskStudentIds.contains(studentId);

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([
      _getStudents().then((v) => _students = v).catchError((_) => _students = _students),
      _getAlerts(onlyUnread: true).then((v) => _alerts = v).catchError((_) => _alerts = _alerts),
      _loadGroupSummaries(),
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
