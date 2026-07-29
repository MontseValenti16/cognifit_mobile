import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/tracking_providers.dart';
import '../../domain/entities/tracking_entity.dart';
import '../../domain/usecases/get_learning_curve_usecase.dart';
import '../../domain/usecases/get_student_metrics_usecase.dart';

typedef LearningCurveData = ({LearningCurveEntity curve, StudentMetricsEntity metrics});

/// El estado ES el AsyncValue: no hay campos síncronos aparte de los datos
/// cargados, así que envolver un objeto extra sería ceremonia sin beneficio.
/// A diferencia de `calendarioViewModelProvider` (AsyncNotifier, carga
/// automática en `build()`), acá el `studentId` llega en tiempo de uso vía
/// `load(id)`, así que se modela como `Notifier<AsyncValue<T>>` con carga manual.
class LearningCurveNotifier extends Notifier<AsyncValue<LearningCurveData>> {
  late GetLearningCurveUseCase _getLearningCurve;
  late GetStudentMetricsUseCase _getStudentMetrics;

  @override
  AsyncValue<LearningCurveData> build() {
    final repo = ref.watch(trackingRepositoryProvider);
    _getLearningCurve = GetLearningCurveUseCase(repo);
    _getStudentMetrics = GetStudentMetricsUseCase(repo);
    return const AsyncValue.loading();
  }

  Future<void> load(String studentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final curve = await _getLearningCurve(studentId);
      final metrics = await _getStudentMetrics(studentId);
      return (curve: curve, metrics: metrics);
    });
  }
}

final learningCurveViewModelProvider =
    NotifierProvider<LearningCurveNotifier, AsyncValue<LearningCurveData>>(LearningCurveNotifier.new);
