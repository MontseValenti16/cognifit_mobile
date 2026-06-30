import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const StatCard({super.key, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color.withOpacity(0.8))),
        ]),
      ),
    );
  }
}

class AlertBanner extends StatelessWidget {
  final String message;
  final VoidCallback onTap;
  const AlertBanner({super.key, required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.warning.withOpacity(0.3))),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5C4200), fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('Ver alerta →', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.warning, fontWeight: FontWeight.w600)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.warning),
        ]),
      ),
    );
  }
}

/// Tarjeta de riesgo por grupo (HU-FL-08): muestra conteos HIGH/MEDIUM/LOW
/// y una barra proporcional de color para identificar grupos en riesgo de un vistazo.
class GroupRiskSummaryCard extends StatelessWidget {
  final GroupRiskSummary summary;
  const GroupRiskSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = summary.totalStudents > 0 ? summary.totalStudents : 1;
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.outline.withOpacity(0.4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(summary.displayName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${summary.totalStudents} alumnos', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF9E9CAD))),
        const SizedBox(height: 12),
        // Proportional color bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(children: [
            if (summary.highRisk > 0) Flexible(flex: summary.highRisk, child: Container(height: 8, color: AppTheme.riskRed)),
            if (summary.mediumRisk > 0) Flexible(flex: summary.mediumRisk, child: Container(height: 8, color: AppTheme.pendingOrange)),
            if (summary.lowRisk > 0) Flexible(flex: summary.lowRisk, child: Container(height: 8, color: AppTheme.activeGreen)),
            Flexible(flex: total - summary.highRisk - summary.mediumRisk - summary.lowRisk > 0 ? total - summary.highRisk - summary.mediumRisk - summary.lowRisk : 0,
                child: Container(height: 8, color: AppTheme.outline.withOpacity(0.2))),
          ].where((w) => true).toList()),
        ),
        const SizedBox(height: 10),
        Row(children: [
          _RiskChip(count: summary.highRisk, color: AppTheme.riskRed, label: 'Alto'),
          const SizedBox(width: 6),
          _RiskChip(count: summary.mediumRisk, color: AppTheme.pendingOrange, label: 'Medio'),
          const SizedBox(width: 6),
          _RiskChip(count: summary.lowRisk, color: AppTheme.activeGreen, label: 'Bajo'),
        ]),
      ]),
    );
  }
}

class _RiskChip extends StatelessWidget {
  final int count;
  final Color color;
  final String label;
  const _RiskChip({required this.count, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text('$count $label', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class DashboardStudentTile extends StatelessWidget {
  final StudentEntity student;
  final bool atRisk;
  final VoidCallback onTap;
  const DashboardStudentTile({super.key, required this.student, required this.atRisk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = atRisk ? AppTheme.riskRed : (student.isActive ? AppTheme.activeGreen : AppTheme.pendingOrange);
    final label = atRisk ? 'En riesgo' : (student.isActive ? 'Activo' : 'Inactivo');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.outline.withOpacity(0.5))),
        child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(student.fullName, style: Theme.of(context).textTheme.titleMedium),
            if (student.birthYear != null) Text('${student.age} años', style: Theme.of(context).textTheme.bodyMedium),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
        ]),
      ),
    );
  }
}
