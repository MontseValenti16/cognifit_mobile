import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../students/domain/entities/student_entity.dart';

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
