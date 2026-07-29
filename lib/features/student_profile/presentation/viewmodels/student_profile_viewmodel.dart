import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../students/di/students_providers.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/domain/usecases/get_student_by_id_usecase.dart';
import '../../../tests/di/tests_providers.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tests/domain/usecases/get_latest_risk_usecase.dart';
import '../../../tests/domain/usecases/get_student_assignments_usecase.dart';
import '../../../tests/domain/usecases/open_session_usecase.dart';
import '../../../tracking/di/tracking_providers.dart';
import '../../../tracking/domain/entities/tracking_entity.dart';
import '../../../tracking/domain/usecases/get_student_metrics_usecase.dart';

class StudentProfileData {
  final StudentEntity student;
  final DiagnosisEntity? latestRisk;
  final StudentMetricsEntity? metrics;
  final List<PendingModuleEntity> pendingModules;
  final String? openingAssignmentId;

  const StudentProfileData({
    required this.student,
    this.latestRisk,
    this.metrics,
    this.pendingModules = const [],
    this.openingAssignmentId,
  });

  bool get hasDiagnosis => latestRisk != null;

  StudentProfileData copyWith({
    StudentEntity? student,
    DiagnosisEntity? latestRisk,
    StudentMetricsEntity? metrics,
    List<PendingModuleEntity>? pendingModules,
    Object? openingAssignmentId = _unset,
  }) {
    return StudentProfileData(
      student: student ?? this.student,
      latestRisk: latestRisk ?? this.latestRisk,
      metrics: metrics ?? this.metrics,
      pendingModules: pendingModules ?? this.pendingModules,
      openingAssignmentId: identical(openingAssignmentId, _unset) ? this.openingAssignmentId : openingAssignmentId as String?,
    );
  }
}

const _unset = Object();

class StudentProfileNotifier extends Notifier<AsyncValue<StudentProfileData>> {
  late GetStudentByIdUseCase _getStudent;
  late GetLatestRiskUseCase _getLatestRisk;
  late GetStudentMetricsUseCase _getMetrics;
  late GetStudentAssignmentsUseCase _getAssignments;
  late OpenSessionUseCase _openSession;

  @override
  AsyncValue<StudentProfileData> build() {
    _getStudent = GetStudentByIdUseCase(ref.watch(studentRepositoryProvider));
    _getLatestRisk = GetLatestRiskUseCase(ref.watch(screeningRepositoryProvider));
    _getMetrics = GetStudentMetricsUseCase(ref.watch(trackingRepositoryProvider));
    _getAssignments = GetStudentAssignmentsUseCase(ref.watch(screeningRepositoryProvider));
    _openSession = OpenSessionUseCase(ref.watch(screeningRepositoryProvider));
    return const AsyncValue.loading();
  }

  Future<void> load(String studentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final student = await _getStudent(studentId);
      DiagnosisEntity? latestRisk;
      StudentMetricsEntity? metrics;
      List<PendingModuleEntity> pendingModules = [];
      try { latestRisk = await _getLatestRisk(studentId); } catch (_) {}
      try { metrics = await _getMetrics(studentId); } catch (_) {}
      try { pendingModules = await _getAssignments(studentId); } catch (_) {}
      return StudentProfileData(
        student: student,
        latestRisk: latestRisk,
        metrics: metrics,
        pendingModules: pendingModules,
      );
    });
  }

  Future<({String sessionId, String moduleTitle})?> openModule(PendingModuleEntity module) async {
    final current = state.valueOrNull;
    if (current == null) return null;
    state = AsyncValue.data(current.copyWith(openingAssignmentId: module.assignmentId));
    try {
      final session = await _openSession(
        assignmentId: module.assignmentId,
        moduleCode: module.moduleCode,
        deviceId: 'flutter-app',
        appVersion: '1.0.0',
      );
      return (sessionId: session.id, moduleTitle: module.moduleName);
    } catch (e) {
      if (kDebugMode) debugPrint('openModule error: $e');
      return null;
    } finally {
      final latest = state.valueOrNull;
      if (latest != null) state = AsyncValue.data(latest.copyWith(openingAssignmentId: null));
    }
  }
}

final studentProfileViewModelProvider =
    NotifierProvider<StudentProfileNotifier, AsyncValue<StudentProfileData>>(StudentProfileNotifier.new);
