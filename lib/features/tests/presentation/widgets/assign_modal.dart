import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/test_entity.dart';
import '../viewmodels/tests_viewmodel.dart';

/// Bottom sheet modal: select student → assign or start now
class AssignTestModal extends StatelessWidget {
  final TestsViewModel vm;
  final VoidCallback onStartNow;
  final VoidCallback onAssignLater;

  const AssignTestModal({
    super.key,
    required this.vm,
    required this.onStartNow,
    required this.onAssignLater,
  });

  @override
  Widget build(BuildContext context) {
    final test = vm.selectedTest!;
    final students = vm.students;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(context.hPad, 12, context.hPad, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Handle bar
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outline, borderRadius: BorderRadius.circular(4)))),
        const SizedBox(height: 16),

        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.assignment_rounded, color: AppTheme.warning, size: 16),
            const SizedBox(width: 6),
            Text('Test Seleccionado', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.warning, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 12),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(test.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700))),
          IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context), color: const Color(0xFF9E9CAD)),
        ]),

        Text('Selecciona el alumno al que se le aplicará esta evaluación:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6880))),
        const SizedBox(height: 16),

        // Student list
        if (vm.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppTheme.primary)))
        else
          ...students.map((s) => _StudentOption(
            student: s,
            isSelected: vm.selectedStudentId == s.id,
            onTap: () => vm.selectStudent(s.id),
          )),

        const SizedBox(height: 24),

        // Primary action
        ListenableBuilder(
          listenable: vm,
          builder: (_, __) => ElevatedButton(
            onPressed: vm.selectedStudentId != null && !vm.isAssigning ? onAssignLater : null,
            child: vm.isAssigning
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Asignar y guardar en historial'),
          ),
        ),
        const SizedBox(height: 10),

        // Secondary action
        ListenableBuilder(
          listenable: vm,
          builder: (_, __) => SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: vm.selectedStudentId != null && !vm.isAssigning ? onStartNow : null,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Iniciar test ahora con el alumno'),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.activeGreen.withOpacity(0.08),
                side: BorderSide(color: AppTheme.activeGreen.withOpacity(0.4)),
                foregroundColor: AppTheme.activeGreen,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _StudentOption extends StatelessWidget {
  final AssignableStudentEntity student;
  final bool isSelected;
  final VoidCallback onTap;

  const _StudentOption({required this.student, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outline.withOpacity(0.5), width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          // Avatar initials
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : const Color(0xFFE0D9ED),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(student.initials, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: isSelected ? Colors.white : AppTheme.primary, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(student.fullName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
            Text(student.grade, style: Theme.of(context).textTheme.bodyMedium),
          ])),
          if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 24)
          else Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.outline))),
        ]),
      ),
    );
  }
}
