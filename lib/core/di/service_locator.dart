/// Manual Dependency Injection — no external DI library.
/// Wires: ApiClient (shared) -> per-feature RemoteDataSource -> Repository -> UseCases -> ViewModel.
/// To point at a real backend, only core/network/api_config.dart needs to change.

import '../network/api_client.dart';
import '../storage/token_storage.dart';

// AUTH
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_me_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';

// STUDENTS
import '../../features/students/data/datasources/student_remote_datasource.dart';
import '../../features/students/data/repositories/student_repository_impl.dart';
import '../../features/students/domain/usecases/get_students_usecase.dart';
import '../../features/students/domain/usecases/get_student_by_id_usecase.dart';
import '../../features/students/domain/usecases/create_student_usecase.dart';
import '../../features/students/domain/usecases/update_student_usecase.dart';
import '../../features/students/domain/usecases/delete_student_usecase.dart';
import '../../features/students/domain/usecases/permanent_delete_student_usecase.dart';
import '../../features/students/domain/usecases/activate_student_usecase.dart';
import '../../features/students/presentation/viewmodels/students_viewmodel.dart';

// GROUPS
import '../../features/groups/data/datasources/group_remote_datasource.dart';
import '../../features/groups/data/repositories/group_repository_impl.dart';
import '../../features/groups/domain/usecases/get_groups_usecase.dart';
import '../../features/groups/domain/usecases/create_group_usecase.dart';

// SCREENING (tests feature)
import '../../features/tests/data/datasources/screening_remote_datasource.dart';
import '../../features/tests/data/repositories/screening_repository_impl.dart';
import '../../features/tests/domain/usecases/get_teacher_items_usecase.dart';
import '../../features/tests/domain/usecases/submit_teacher_results_usecase.dart';
import '../../features/tests/domain/usecases/get_catalog_usecase.dart';
import '../../features/tests/domain/usecases/assign_battery_usecase.dart';
import '../../features/tests/domain/usecases/open_session_usecase.dart';
import '../../features/tests/domain/usecases/get_session_items_usecase.dart';
import '../../features/tests/domain/usecases/submit_responses_usecase.dart';
import '../../features/tests/domain/usecases/diagnose_usecase.dart';
import '../../features/tests/domain/usecases/get_latest_risk_usecase.dart';
import '../../features/tests/domain/usecases/get_student_assignments_usecase.dart';
import '../../features/tests/presentation/viewmodels/tests_viewmodel.dart';

// EXERCISE (consumes screening repository)
import '../../features/exercise/presentation/viewmodels/exercise_viewmodel.dart';

// TRACKING
import '../../features/tracking/data/datasources/tracking_remote_datasource.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/tracking/domain/usecases/get_learning_curve_usecase.dart';
import '../../features/tracking/domain/usecases/get_student_metrics_usecase.dart';
import '../../features/tracking/domain/usecases/get_group_metrics_usecase.dart';
import '../../features/tracking/domain/usecases/get_alerts_usecase.dart';
import '../../features/tracking/domain/usecases/mark_alert_read_usecase.dart';
import '../../features/tracking/presentation/viewmodels/tracking_viewmodel.dart';
import '../../features/tracking/presentation/viewmodels/learning_curve_viewmodel.dart';

// STUDENT PROFILE (composes students + screening + tracking)
import '../../features/student_profile/presentation/viewmodels/student_profile_viewmodel.dart';

// INTERVENTION
import '../../features/intervention/data/datasources/intervention_remote_datasource.dart';
import '../../features/intervention/data/repositories/intervention_repository_impl.dart';
import '../../features/intervention/domain/usecases/get_active_path_usecase.dart';
import '../../features/intervention/domain/usecases/next_exercise_usecase.dart';
import '../../features/intervention/presentation/viewmodels/intervention_viewmodel.dart';

// REPORTS
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/usecases/request_report_usecase.dart';
import '../../features/reports/domain/usecases/generate_report_usecase.dart';
import '../../features/reports/domain/usecases/download_report_usecase.dart';
import '../../features/reports/presentation/viewmodels/reports_viewmodel.dart';

// DASHBOARD (composes students + tracking)
import '../../features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  // ── Singletons: infra ──────────────────────────────────────────────────────
  final TokenStorage tokenStorage = TokenStorage();
  late final ApiClient apiClient = ApiClient(tokenStorage);

  // ── Repositories (built once, reused by every use case) ────────────────────
  late final AuthRepositoryImpl _authRepo = AuthRepositoryImpl(AuthRemoteDataSourceImpl(apiClient), tokenStorage);
  late final StudentRepositoryImpl _studentRepo = StudentRepositoryImpl(StudentRemoteDataSourceImpl(apiClient));
  late final GroupRepositoryImpl _groupRepo = GroupRepositoryImpl(GroupRemoteDataSourceImpl(apiClient));
  late final ScreeningRepositoryImpl _screeningRepo = ScreeningRepositoryImpl(ScreeningRemoteDataSourceImpl(apiClient));
  late final TrackingRepositoryImpl _trackingRepo = TrackingRepositoryImpl(TrackingRemoteDataSourceImpl(apiClient));
  late final InterventionRepositoryImpl _interventionRepo = InterventionRepositoryImpl(InterventionRemoteDataSourceImpl(apiClient));
  late final ReportRepositoryImpl _reportRepo = ReportRepositoryImpl(ReportRemoteDataSourceImpl(apiClient));

  // ── ViewModels (lazily instantiated, cached) ────────────────────────────────
  AuthViewModel? _auth;
  StudentsViewModel? _students;
  TestsViewModel? _tests;
  ExerciseViewModel? _exercise;
  TrackingViewModel? _tracking;
  LearningCurveViewModel? _learningCurve;
  StudentProfileViewModel? _studentProfile;
  DashboardViewModel? _dashboard;
  ReportsViewModel? _reports;

  AuthViewModel get authViewModel => _auth ??= AuthViewModel(
    login: LoginUseCase(_authRepo),
    logout: LogoutUseCase(_authRepo),
    getMe: GetMeUseCase(_authRepo),
    register: RegisterUseCase(_authRepo),
    tokenStorage: tokenStorage,
  );

  StudentsViewModel get studentsViewModel => _students ??= StudentsViewModel(
    getStudents: GetStudentsUseCase(_studentRepo),
    getStudentById: GetStudentByIdUseCase(_studentRepo),
    createStudent: CreateStudentUseCase(_studentRepo),
    updateStudent: UpdateStudentUseCase(_studentRepo),
    deleteStudent: DeleteStudentUseCase(_studentRepo),
    permanentDeleteStudent: PermanentDeleteStudentUseCase(_studentRepo),
    activateStudent: ActivateStudentUseCase(_studentRepo),
    getGroups: GetGroupsUseCase(_groupRepo),
    createGroup: CreateGroupUseCase(_groupRepo),
  );

  TestsViewModel get testsViewModel => _tests ??= TestsViewModel(
    getTeacherItems: GetTeacherItemsUseCase(_screeningRepo),
    submitTeacherResults: SubmitTeacherResultsUseCase(_screeningRepo),
    getCatalog: GetCatalogUseCase(_screeningRepo),
    assignBattery: AssignBatteryUseCase(_screeningRepo),
    openSession: OpenSessionUseCase(_screeningRepo),
  );

  ExerciseViewModel get exerciseViewModel => _exercise ??= ExerciseViewModel(
    getItems: GetSessionItemsUseCase(_screeningRepo),
    submitResponses: SubmitResponsesUseCase(_screeningRepo),
    diagnose: DiagnoseUseCase(_screeningRepo),
  );

  TrackingViewModel get trackingViewModel => _tracking ??= TrackingViewModel(
    getAlerts: GetAlertsUseCase(_trackingRepo),
    markAlertRead: MarkAlertReadUseCase(_trackingRepo),
    getGroupMetrics: GetGroupMetricsUseCase(_trackingRepo),
  );

  LearningCurveViewModel get learningCurveViewModel => _learningCurve ??= LearningCurveViewModel(
    getLearningCurve: GetLearningCurveUseCase(_trackingRepo),
    getStudentMetrics: GetStudentMetricsUseCase(_trackingRepo),
  );

  StudentProfileViewModel get studentProfileViewModel => _studentProfile ??= StudentProfileViewModel(
    getStudent: GetStudentByIdUseCase(_studentRepo),
    getLatestRisk: GetLatestRiskUseCase(_screeningRepo),
    getMetrics: GetStudentMetricsUseCase(_trackingRepo),
    getAssignments: GetStudentAssignmentsUseCase(_screeningRepo),
    openSession: OpenSessionUseCase(_screeningRepo),
  );

  DashboardViewModel get dashboardViewModel => _dashboard ??= DashboardViewModel(
    getStudents: GetStudentsUseCase(_studentRepo),
    getAlerts: GetAlertsUseCase(_trackingRepo),
    getGroups: GetGroupsUseCase(_groupRepo),
    getGroupMetrics: GetGroupMetricsUseCase(_trackingRepo),
  );

  InterventionViewModel interventionViewModel() => InterventionViewModel(
    getActivePath: GetActivePathUseCase(_interventionRepo),
    nextExercise: NextExerciseUseCase(_interventionRepo),
  );

  ReportsViewModel get reportsViewModel => _reports ??= ReportsViewModel(
    requestReport: RequestReportUseCase(_reportRepo),
    generateReport: GenerateReportUseCase(_reportRepo),
    downloadReport: DownloadReportUseCase(_reportRepo),
  );

  /// Call after logout to drop cached state tied to the previous session.
  void resetSessionScopedViewModels() {
    _students = null; _tests = null; _exercise = null; _tracking = null;
    _learningCurve = null; _studentProfile = null; _dashboard = null; _reports = null;
  }
}
