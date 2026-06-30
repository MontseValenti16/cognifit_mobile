import 'package:flutter/foundation.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/domain/usecases/get_students_usecase.dart';
import '../../../tracking/domain/entities/tracking_entity.dart';
import '../../../tracking/domain/usecases/get_alerts_usecase.dart';

/// The dashboard has no single backend endpoint — it composes:
/// GET /students (for counts + active list) + GET /tracking/alerts (for the banner).
/// Group-level risk metrics (GET /tracking/groups/{id}/metrics) need a group_id,
/// which isn't available until a Groups list endpoint exists; omitted for now.
class DashboardViewModel extends ChangeNotifier {
  final GetStudentsUseCase _getStudents;
  final GetAlertsUseCase _getAlerts;

  DashboardViewModel({required GetStudentsUseCase getStudents, required GetAlertsUseCase getAlerts})
      : _getStudents = getStudents, _getAlerts = getAlerts;

  bool _isLoading = false;
  List<StudentEntity> _students = [];
  List<AlertEntity> _alerts = [];

  bool get isLoading => _isLoading;
  List<StudentEntity> get students => _students;
  List<StudentEntity> get recentStudents => _students.take(5).toList();

  int get totalStudents => _students.length;
  Set<String> get _atRiskStudentIds => _alerts.where((a) => a.urgency == 'HIGH').map((a) => a.studentId).toSet();
  int get atRiskCount => _atRiskStudentIds.length;
  List<AlertEntity> get unreadAlerts => _alerts.where((a) => !a.isRead).toList();
  AlertEntity? get topAlert => unreadAlerts.isEmpty ? null : unreadAlerts.first;

  bool isStudentAtRisk(String studentId) => _atRiskStudentIds.contains(studentId);

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      _students = await _getStudents();
      _alerts = await _getAlerts(onlyUnread: true);
    } catch (_) {
      // Surfaced via empty states in the UI; dashboard stays usable even if one call fails.
    }
    _isLoading = false;
    notifyListeners();
  }

  void dismissTopAlert() {
    if (topAlert == null) return;
    _alerts = _alerts.where((a) => a.id != topAlert!.id).toList();
    notifyListeners();
  }
}
