import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../features/student_profile/presentation/screens/student_profile_screen.dart';
import '../../features/tests/presentation/screens/tests_screen.dart';
import '../../features/exercise/presentation/screens/exercise_screen.dart';

class AppRouter {
  static const String splash    = '/';
  static const String login     = '/login';
  static const String dashboard = '/dashboard';
  static const String students  = '/students';
  static const String tests     = '/tests';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash,    builder: (c, s) => const SplashScreen()),
      GoRoute(path: login,     builder: (c, s) => const LoginScreen()),
      GoRoute(path: dashboard, builder: (c, s) => const DashboardScreen()),
      GoRoute(path: students,  builder: (c, s) => const StudentsScreen()),
      GoRoute(path: tests,     builder: (c, s) => const TestsScreen()),

      GoRoute(
        path: '/student/:id',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          return StudentProfileScreen(studentId: s.pathParameters['id'] ?? '', studentName: extra?['name'] ?? 'Alumno');
        },
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
    ],
  );
}
