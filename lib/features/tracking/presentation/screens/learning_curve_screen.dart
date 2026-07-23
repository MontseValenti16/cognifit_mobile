import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../viewmodels/learning_curve_viewmodel.dart';
import '../widgets/learning_curve_chart.dart';

class LearningCurveScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  const LearningCurveScreen({super.key, required this.studentId, required this.studentName});

  @override
  State<LearningCurveScreen> createState() => _LearningCurveScreenState();
}

class _LearningCurveScreenState extends State<LearningCurveScreen> {
  late final LearningCurveViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.learningCurveViewModel;
    _vm.addListener(_rebuild);
    _vm.load(widget.studentId);
  }

  @override
  void dispose() {
    _vm.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Progreso', style: Theme.of(context).textTheme.titleLarge),
          Text(widget.studentName, style: Theme.of(context).textTheme.bodyMedium),
        ]),
        actions: const [ThemeToggleButton()],
      ),
      body: _vm.isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _vm.status == LearningCurveStatus.error
              ? _ErrorBody(message: _vm.error ?? 'Error al cargar', onRetry: () => _vm.load(widget.studentId))
              : RefreshIndicator(
                  onRefresh: () => _vm.load(widget.studentId),
                  color: AppTheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (_vm.metrics != null) _MetricsSummary(metrics: _vm.metrics!),
                      const SizedBox(height: 24),
                      Text('Evolución de precisión', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Por número de sesión · % de aciertos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText)),
                      const SizedBox(height: 16),
                      if (_vm.curve != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
                          ),
                          child: LearningCurveChart(curve: _vm.curve!),
                        ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
    );
  }
}

class _MetricsSummary extends StatelessWidget {
  final dynamic metrics;
  const _MetricsSummary({required this.metrics});

  IconData get _icon => switch (metrics.trend) {
    'improving' => Icons.trending_up_rounded,
    'regressing' => Icons.trending_down_rounded,
    _ => Icons.trending_flat_rounded,
  };

  Color get _color => switch (metrics.trend) {
    'improving' => AppTheme.activeGreen,
    'regressing' => AppTheme.riskRed,
    _ => AppTheme.pendingOrange,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Resumen', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Icon(_icon, color: _color, size: 20),
          const SizedBox(width: 4),
          Text(metrics.trend, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _color, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _Stat(label: 'Sesiones diagnóstico', value: '${metrics.diagnosticSessions}'),
          _Stat(label: 'Sesiones ejercicio', value: '${metrics.exerciseSessions}'),
          _Stat(label: 'Precisión actual', value: '${(metrics.lastAccuracy * 100).toStringAsFixed(0)}%'),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
    const SizedBox(height: 2),
    Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.mutedText)),
  ]));
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.riskRed.withValues(alpha: 0.6)),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
    ]),
  ));
}
