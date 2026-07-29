import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/admin/presentation/viewmodels/admin_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import '../../features/exercise/presentation/viewmodels/exercise_viewmodel.dart';
import '../../features/institutions/presentation/viewmodels/institution_viewmodel.dart';
import '../../features/payments/presentation/viewmodels/payment_viewmodel.dart';
import '../../features/reports/presentation/viewmodels/reports_viewmodel.dart';
import '../../features/specialist/presentation/viewmodels/specialist_viewmodel.dart';
import '../../features/student_profile/presentation/viewmodels/student_profile_viewmodel.dart';
import '../../features/students/presentation/viewmodels/students_viewmodel.dart';
import '../../features/tests/presentation/viewmodels/tests_viewmodel.dart';
import '../../features/tracking/presentation/viewmodels/tracking_viewmodel.dart';
import '../../features/tracking/presentation/viewmodels/learning_curve_viewmodel.dart';

void invalidateSessionScopedProviders(WidgetRef ref) {
  ref.invalidate(studentsViewModelProvider);
  ref.invalidate(trackingViewModelProvider);
  ref.invalidate(learningCurveViewModelProvider);
  ref.invalidate(dashboardViewModelProvider);
  ref.invalidate(testsViewModelProvider);
  ref.invalidate(studentProfileViewModelProvider);
  ref.invalidate(reportsViewModelProvider);
  ref.invalidate(exerciseViewModelProvider);
  ref.invalidate(adminViewModelProvider);
  ref.invalidate(institutionViewModelProvider);
  ref.invalidate(specialistViewModelProvider);
  ref.invalidate(paymentViewModelProvider);
}
