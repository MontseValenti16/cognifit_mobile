import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/student_entity.dart';
import '../viewmodels/students_viewmodel.dart';
import '../widgets/students_widgets.dart';
import '../widgets/student_form_modal.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late final StudentsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.studentsViewModel;
    _vm.addListener(_rebuild);
    _vm.loadStudents();
  }

  @override
  void dispose() { _vm.removeListener(_rebuild); super.dispose(); }
  void _rebuild() { if (mounted) setState(() {}); }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _openForm({StudentEntity? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListenableBuilder(
        listenable: _vm,
        builder: (_, __) => StudentFormModal(
          existing: existing,
          defaultGroupId: existing?.groupId ?? 'default-group-id', // TODO: real group selector once /groups exists
          isSaving: _vm.isMutating,
          onSubmit: (name, year, gender) async {
            final ok = existing == null
              ? await _vm.create(CreateStudentParams(groupId: 'default-group-id', fullName: name, birthYear: year, gender: gender))
              : await _vm.update(UpdateStudentParams(studentId: existing.id, fullName: name, birthYear: year, gender: gender));
            if (ok && mounted) {
              Navigator.pop(context);
              _showSnack(existing == null ? '✓ Alumno creado' : '✓ Cambios guardados', AppTheme.activeGreen);
            } else if (mounted) {
              _showSnack(_vm.error ?? 'Ocurrió un error', AppTheme.riskRed);
            }
          },
        ),
      ),
    );
  }

  void _confirmDelete(StudentEntity student) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('¿Eliminar alumno?'),
      content: Text('Se eliminará a ${student.fullName} de tu lista. Esta acción no se puede deshacer.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final ok = await _vm.delete(student.id);
            _showSnack(ok ? '✓ Alumno eliminado' : (_vm.error ?? 'No se pudo eliminar'), ok ? AppTheme.activeGreen : AppTheme.riskRed);
          },
          child: Text('Eliminar', style: TextStyle(color: AppTheme.riskRed)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(context.hPad, 20, context.hPad, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero),
                const SizedBox(width: 4),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Alumnos', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
                  Text('${_vm.totalCount} en total · ${_vm.activeCount} activos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6880))),
                ])),
                IconButton.filled(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                ),
              ]),
              const SizedBox(height: 14),
              StudentsSearchBar(onChanged: _vm.search),
            ]),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _vm.error != null && _vm.students.isEmpty
                ? _ErrorState(message: _vm.error!, onRetry: _vm.loadStudents)
                : _vm.students.isEmpty
                  ? StudentsEmptyState(onAdd: () => _openForm())
                  : RefreshIndicator(
                      onRefresh: _vm.loadStudents,
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(context.hPad, 0, context.hPad, 90),
                        itemCount: _vm.students.length,
                        itemBuilder: (context, i) {
                          final s = _vm.students[i];
                          return StudentListTile(
                            student: s,
                            onTap: () => context.push('/student/${s.id}', extra: {'name': s.fullName}),
                            onEdit: () => _openForm(existing: s),
                            onDelete: () => _confirmDelete(s),
                          );
                        },
                      ),
                    ),
          ),
        ]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.riskRed.withOpacity(0.6)),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 16),
      OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
    ]),
  ));
}
