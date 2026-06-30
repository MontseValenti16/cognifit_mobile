import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
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
      Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.riskRed.withOpacity(0.6)),
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
          const SizedBox(height: 16),
        ] else
          _NoDiagnosisCard(),

        if (metrics != null) ...[
          const SizedBox(height: 16),
          _MetricsCard(metrics: metrics),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.outline.withOpacity(0.5))),
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
            decoration: BoxDecoration(color: AppTheme.riskRed.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('Inactivo', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.riskRed))),
      ]),
    );
  }
}

class _NoDiagnosisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppTheme.primaryContainer.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
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
      decoration: BoxDecoration(color: _color.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: _color.withOpacity(0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: _color, size: 18),
          const SizedBox(width: 8),
          Text('DIAGNÓSTICO', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _color, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
          if (risk.plnSource == 'fallback') ...[
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.pendingOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('Modo local', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.pendingOrange))),
          ],
        ]),
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
          value: risk.riskProbability, minHeight: 8, backgroundColor: AppTheme.outline.withOpacity(0.3), valueColor: AlwaysStoppedAnimation(_color))),
        const SizedBox(height: 6),
        Text('Riesgo ${risk.riskLevel} · ${(risk.riskProbability * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _color, fontWeight: FontWeight.w600)),
        if (risk.mainErrorCodes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: risk.mainErrorCodes.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.outline.withOpacity(0.5))),
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
