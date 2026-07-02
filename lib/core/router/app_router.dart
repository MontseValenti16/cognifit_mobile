import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../features/student_profile/presentation/screens/student_profile_screen.dart';
import '../../features/tests/presentation/screens/tests_screen.dart';
import '../../features/exercise/presentation/screens/exercise_screen.dart';
import '../../features/tracking/presentation/screens/alerts_screen.dart';
import '../../features/tracking/presentation/screens/learning_curve_screen.dart';
import '../../features/child/presentation/screens/child_home_screen.dart';
import '../../features/specialist/presentation/screens/specialist_review_screen.dart';
import '../../features/parent/presentation/screens/parent_home_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';

class AppRouter {
  static const String splash             = '/';
  static const String login              = '/login';
  static const String dashboard          = '/dashboard';
  static const String students           = '/students';
  static const String tests              = '/tests';
  static const String alerts             = '/alerts';
  static const String progress           = '/student/:id/progress';
  static const String specialistReview   = '/specialist/review';
  static const String parentHome         = '/parent';
  static const String adminUsers         = '/admin/users';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash,    builder: (c, s) => const SplashScreen()),
      GoRoute(path: login,     builder: (c, s) => const LoginScreen()),
      GoRoute(path: dashboard, builder: (c, s) => const DashboardScreen()),
      GoRoute(
        path: students,
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          return StudentsScreen(initialGroupId: extra?['groupId']);
        },
      ),
      GoRoute(path: tests,     builder: (c, s) => const TestsScreen()),
      GoRoute(path: alerts,    builder: (c, s) => const AlertsScreen()),

      GoRoute(
        path: '/student/:id',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          return StudentProfileScreen(studentId: s.pathParameters['id'] ?? '', studentName: extra?['name'] ?? 'Alumno');
        },
        routes: [
          GoRoute(
            path: 'progress',
            builder: (c, s) {
              final extra = s.extra as Map<String, dynamic>?;
              return LearningCurveScreen(
                studentId: s.pathParameters['id'] ?? '',
                studentName: extra?['name'] ?? 'Alumno',
              );
            },
          ),
        ],
      ),

      // Real screening session — backend sessionId, not a static testId
      GoRoute(
        path: '/exercise-session/:sessionId',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          return ExerciseScreen(
            sessionId: s.pathParameters['sessionId'] ?? '',
            moduleTitle: extra?['moduleTitle'] ?? 'Módulo',
          );
        },
      ),

      // Revisión clínica para SPECIALIST
      GoRoute(
        path: specialistReview,
        builder: (c, s) => const SpecialistReviewScreen(),
      ),

      // Panel de administración — solo ADMIN
      GoRoute(
        path: adminUsers,
        builder: (c, s) => const AdminUsersScreen(),
      ),

      // Vista de padre: perfil de su hijo en modo lectura
      GoRoute(
        path: parentHome,
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          return ParentHomeScreen(
            studentId: extra?['studentId'] ?? '',
            studentName: extra?['name'] ?? 'Alumno',
          );
        },
      ),

      // Modo niño — pantalla gamificada entregada al alumno por el docente
      GoRoute(
        path: '/child/:studentId',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          return ChildHomeScreen(
            studentId: s.pathParameters['studentId'] ?? '',
            studentName: extra?['name'] ?? 'Alumno',
            pendingSessionId: extra?['sessionId'],
            pendingModuleTitle: extra?['moduleTitle'],
          );
        },
      ),
    ],
  );

  static const String childHome = '/child/:studentId';
  static String childHomeOf(String studentId) => '/child/$studentId';
}
