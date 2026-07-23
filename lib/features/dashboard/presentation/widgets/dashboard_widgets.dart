import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const StatCard({super.key, required this.value, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: color, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color.withValues(alpha: 0.8))),
          ]),
        ),
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
        decoration: BoxDecoration(color: AppTheme.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3))),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('Ver alerta →', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.warning, fontWeight: FontWeight.w600)),
          ])),
          Icon(Icons.chevron_right_rounded, color: AppTheme.warning),
        ]),
      ),
    );
  }
}

class GroupRiskSummaryCard extends StatelessWidget {
  final GroupRiskSummary summary;
  final VoidCallback? onTap;
  const GroupRiskSummaryCard({super.key, required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final total = summary.totalStudents > 0 ? summary.totalStudents : 1;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(summary.displayName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${summary.totalStudents} alumnos', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText)),
        const SizedBox(height: 12),
        // Proportional color bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(children: [
            if (summary.highRisk > 0) Flexible(flex: summary.highRisk, child: Container(height: 8, color: AppTheme.riskRed)),
            if (summary.mediumRisk > 0) Flexible(flex: summary.mediumRisk, child: Container(height: 8, color: AppTheme.pendingOrange)),
            if (summary.lowRisk > 0) Flexible(flex: summary.lowRisk, child: Container(height: 8, color: AppTheme.activeGreen)),
            Flexible(flex: total - summary.highRisk - summary.mediumRisk - summary.lowRisk > 0 ? total - summary.highRisk - summary.mediumRisk - summary.lowRisk : 0,
                child: Container(height: 8, color: AppTheme.outline.withValues(alpha: 0.2))),
          ].where((w) => true).toList()),
        ),
        const SizedBox(height: 10),
        // Wrap en vez de Row: con las tres etiquetas completas ("0 Alto",
        // "0 Medio", "0 Bajo") el contenido no cabe en los 200px fijos de la
        // tarjeta y un Row desbordaba (banda de overflow amarilla/negra). Con
        // Wrap el chip que no entra baja a una segunda línea en vez de salirse.
        Wrap(spacing: 6, runSpacing: 6, children: [
          _RiskChip(count: summary.highRisk, color: AppTheme.riskRed, label: 'Alto'),
          _RiskChip(count: summary.mediumRisk, color: AppTheme.pendingOrange, label: 'Medio'),
          _RiskChip(count: summary.lowRisk, color: AppTheme.activeGreen, label: 'Bajo'),
        ]),
      ]),
      ),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
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
        decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5))),
        child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(student.fullName, style: Theme.of(context).textTheme.titleMedium),
            if (student.birthYear != null) Text('${student.age} años', style: Theme.of(context).textTheme.bodyMedium),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: AppTheme.mutedText, size: 20),
        ]),
      ),
    );
  }
}
