import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../child/presentation/screens/child_home_screen.dart';
import '../../../intervention/presentation/screens/comprehension_track_screen.dart';
import '../../../intervention/presentation/screens/intervention_screen.dart';
import '../../../reports/presentation/widgets/report_bottom_sheet.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tracking/domain/entities/tracking_entity.dart';
import '../viewmodels/student_profile_viewmodel.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  const StudentProfileScreen({super.key, required this.studentId, required this.studentName});
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late final StudentProfileViewModel _vm;
  @override
  void initState() { super.initState(); _vm = ServiceLocator.instance.studentProfileViewModel; _vm.addListener(_r); _vm.load(widget.studentId); }
  @override
  void dispose() { _vm.removeListener(_r); super.dispose(); }
  void _r() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_vm.student?.fullName ?? widget.studentName, style: Theme.of(context).textTheme.titleLarge),
          Text('Perfil del alumno', style: Theme.of(context).textTheme.bodyMedium),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.child_care_rounded),
            tooltip: 'Modo niño',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChildHomeScreen(
                studentId: widget.studentId,
                studentName: _vm.student?.fullName ?? widget.studentName,
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.show_chart_rounded),
            tooltip: 'Ver progreso',
            onPressed: () => context.push(
              '/student/${widget.studentId}/progress',
              extra: {'name': widget.studentName},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.psychology_rounded),
            tooltip: 'Intervención',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => InterventionScreen(
                vm: ServiceLocator.instance.interventionViewModel(),
                studentId: widget.studentId,
                studentName: widget.studentName,
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Comprensión lectora',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ComprehensionTrackScreen(
                repository: ServiceLocator.instance.interventionRepository,
                studentId: widget.studentId,
                studentName: widget.studentName,
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Generar reporte',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              builder: (_) => ReportBottomSheet(
                vm: ServiceLocator.instance.reportsViewModel,
                studentId: widget.studentId,
                studentName: widget.studentName,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'Asignar nuevo test',
            onPressed: () => context.push('/tests'),
          ),
        ],
      ),
      body: _vm.isLoading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : _vm.status == StudentProfileStatus.error && _vm.student == null
          ? _ErrorBody(message: _vm.error ?? 'Error', onRetry: () => _vm.load(widget.studentId))
          : _ProfileBody(vm: _vm),
    );
  }
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

class _ProfileBody extends StatelessWidget {
  final StudentProfileViewModel vm;
  const _ProfileBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    final student = vm.student;
    final risk = vm.latestRisk;
    final metrics = vm.metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (student != null) _StudentHeaderCard(student: student),
        const SizedBox(height: 16),

        if (risk != null) ...[
          _DiagnosisCard(risk: risk),
          TedePercentilCard(
            nivelLector: risk.tedeNivelLector,
            erroresEspecificos: risk.tedeErroresEspecificos,
          ),
          const SizedBox(height: 16),
        ] else
          _NoDiagnosisCard(),

        if (metrics != null) ...[
          const SizedBox(height: 16),
          _MetricsCard(metrics: metrics),
        ],

        if (vm.pendingModules.isNotEmpty) ...[
          const SizedBox(height: 24),
          _PendingModulesSection(vm: vm),
        ],

        const SizedBox(height: 24),
        _ActionBtn(
          icon: Icons.assignment_outlined, label: 'Asignar nuevo test',
          color: AppTheme.primaryContainer, textColor: AppTheme.primary,
          onTap: () => context.push('/tests'),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }
}

class _StudentHeaderCard extends StatelessWidget {
  final dynamic student; // StudentEntity (from students feature)
  const _StudentHeaderCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5))),
      child: Row(children: [
        CircleAvatar(radius: 28, backgroundColor: AppTheme.primaryContainer,
          child: Text(student.fullName.substring(0,1), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 22))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(student.fullName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          if (student.birthYear != null) Text('${student.age} años', style: Theme.of(context).textTheme.bodyMedium),
        ])),
        if (!student.isActive)
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.riskRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('Inactivo', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.riskRed))),
      ]),
    );
  }
}

class _NoDiagnosisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      const Icon(Icons.info_outline_rounded, color: AppTheme.primary),
      const SizedBox(width: 12),
      Expanded(child: Text('Este alumno aún no tiene un diagnóstico. Asígnale una batería desde "Tests".',
        style: Theme.of(context).textTheme.bodyMedium)),
    ]),
  );
}

class _DiagnosisCard extends StatelessWidget {
  final DiagnosisEntity risk;
  const _DiagnosisCard({required this.risk});

  Color get _color => switch (risk.riskLevel) {
    'HIGH' => AppTheme.riskRed,
    'MEDIUM' => AppTheme.pendingOrange,
    _ => AppTheme.activeGreen,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: _color.withValues(alpha: 0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: _color, size: 18),
          const SizedBox(width: 8),
          Text('DIAGNÓSTICO', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _color, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
          if (risk.plnSource == 'local_fallback') ...[
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.pendingOrange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('Sin el modelo', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.pendingOrange, fontWeight: FontWeight.w700))),
          ],
        ]),
        // El aviso decía "Modo local", que no le dice nada a un docente. El
        // riesgo de este caso es que el resultado se ve igual de normal que
        // uno bueno, así que conviene explicar qué significa y qué hacer.
        if (risk.plnSource == 'local_fallback') ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.pendingOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.pendingOrange.withValues(alpha: 0.35)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.pendingOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Este resultado se calculó con el método de respaldo porque el '
                  'servicio de análisis no respondió. Tómalo como orientación y '
                  'repite el diagnóstico cuando el servicio esté disponible.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B6880), height: 1.4)),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Subtipo', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF9E9CAD))),
            const SizedBox(height: 4),
            Text(risk.plnSubtype, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: _color, fontWeight: FontWeight.w700)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Severidad', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF9E9CAD))),
            const SizedBox(height: 4),
            Text(risk.plnSeverity, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: _color, fontWeight: FontWeight.w700)),
          ]),
        ]),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
          value: risk.riskProbability, minHeight: 8, backgroundColor: AppTheme.outline.withValues(alpha: 0.3), valueColor: AlwaysStoppedAnimation(_color))),
        const SizedBox(height: 6),
        Text('Riesgo ${risk.riskLevel} · ${(risk.riskProbability * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _color, fontWeight: FontWeight.w600)),
        if (risk.mainErrorCodes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: risk.mainErrorCodes.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: _color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(c, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _color, fontWeight: FontWeight.w600)),
          )).toList()),
        ],
        if (risk.recommendationReason.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(risk.recommendationReason, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6880))),
        ],
      ]),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final StudentMetricsEntity metrics;
  const _MetricsCard({required this.metrics});

  IconData get _trendIcon => switch (metrics.trend) {
    'improving' => Icons.trending_up_rounded,
    'regressing' => Icons.trending_down_rounded,
    _ => Icons.trending_flat_rounded,
  };
  Color get _trendColor => switch (metrics.trend) {
    'improving' => AppTheme.activeGreen,
    'regressing' => AppTheme.riskRed,
    _ => AppTheme.pendingOrange,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Progreso de ejercicios', style: Theme.of(context).textTheme.titleMedium),
          Row(children: [
            Icon(_trendIcon, color: _trendColor, size: 18),
            const SizedBox(width: 4),
            Text(metrics.trend, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _trendColor, fontWeight: FontWeight.w600)),
          ]),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _MiniStat(label: 'Sesiones', value: '${metrics.exerciseSessions}'),
          _MiniStat(label: 'Precisión actual', value: '${(metrics.lastAccuracy * 100).toStringAsFixed(0)}%'),
          _MiniStat(label: 'Precisión inicial', value: '${(metrics.firstAccuracy * 100).toStringAsFixed(0)}%'),
        ]),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
    const SizedBox(height: 2),
    Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF9E9CAD))),
  ]));
}

class _PendingModulesSection extends StatelessWidget {
  final StudentProfileViewModel vm;
  const _PendingModulesSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Módulos pendientes', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      ...vm.pendingModules.map((module) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.psychology_outlined, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(module.moduleName, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(module.moduleCode, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF9E9CAD))),
            ])),
            vm.openingAssignmentId == module.assignmentId
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
              : TextButton(
                  onPressed: vm.openingAssignmentId != null ? null : () async {
                    final result = await vm.openModule(module);
                    if (!context.mounted) return;
                    if (result == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo abrir el módulo. Intenta de nuevo.')));
                      return;
                    }
                    context.push('/exercise-session/${result.sessionId}', extra: {'moduleTitle': result.moduleTitle});
                  },
                  child: const Text('Continuar →'),
                ),
          ]),
        ),
      )),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color, textColor; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.textColor, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
    child: Row(children: [Icon(icon, color: textColor, size: 22), const SizedBox(width: 14),
      Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
      const Spacer(), Icon(Icons.chevron_right_rounded, color: textColor)]),
  ));
}

/// Percentiles normativos del TEDE, al lado de la severidad del modelo. El
/// modelo se entrenó con datos sintéticos y no tiene etiquetas de especialista;
/// el percentil da respaldo normativo. Si coinciden, refuerzan; si difieren,
/// el desacuerdo es señal de que el modelo conviene revisar.
class TedePercentilCard extends StatelessWidget {
  final TedePercentil? nivelLector;
  final TedePercentil? erroresEspecificos;
  const TedePercentilCard({super.key, this.nivelLector, this.erroresEspecificos});

  @override
  Widget build(BuildContext context) {
    if (nivelLector == null && erroresEspecificos == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TEDE — norma por grado',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF9E9CAD), letterSpacing: 1.0, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (nivelLector != null) _fila(context, 'Nivel lector', nivelLector!),
        if (erroresEspecificos != null) _fila(context, 'Errores específicos', erroresEspecificos!),
        if ((nivelLector?.escalado ?? false) || (erroresEspecificos?.escalado ?? false))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'El percentil es orientativo: se calculó sobre una parte de la prueba.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9E9CAD), fontStyle: FontStyle.italic)),
          ),
      ]),
    );
  }

  Widget _fila(BuildContext context, String etiqueta, TedePercentil p) {
    final pg = p.percentilPorGrado;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(etiqueta, style: Theme.of(context).textTheme.bodyMedium),
        Text(pg != null ? 'percentil $pg' : '—',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: pg != null && pg < 15 ? AppTheme.riskRed : AppTheme.onSurface)),
      ]),
    );
  }
}
