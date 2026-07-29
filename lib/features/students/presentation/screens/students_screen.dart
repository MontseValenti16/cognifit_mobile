import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../viewmodels/students_viewmodel.dart';
import '../widgets/students_widgets.dart';
import '../widgets/student_form_modal.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  final String? initialGroupId;
  const StudentsScreen({super.key, this.initialGroupId});
  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  // `ref.read`, no `watch`: se usan en callbacks fuera de build (donde watch
  // no es válido). build() se suscribe aparte con ref.watch(...) al inicio.
  StudentsState get _state => ref.read(studentsViewModelProvider);
  StudentsNotifier get _notifier => ref.read(studentsViewModelProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Ver nota en dashboard_screen: modificar un provider desde initState
    // ocurre durante el build y Riverpod lo rechaza.
    Future(() {
      if (!mounted) return;
      _notifier.loadStudents().then((_) {
        if (mounted && widget.initialGroupId != null) {
          _notifier.filterByGroup(widget.initialGroupId);
        }
      });
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openForm({StudentEntity? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Consumer(
        builder: (_, modalRef, __) {
          final state = modalRef.watch(studentsViewModelProvider);
          return StudentFormModal(
            existing: existing,
            groups: state.groups,
            isSaving: state.isMutating,
            onCreateGroup: _notifier.createGroup,
            onSubmit: (groupId, name, year, gender) async {
              final ok = existing == null
                  ? await _notifier.create(
                      CreateStudentParams(
                        groupId: groupId,
                        fullName: name,
                        birthYear: year,
                        gender: gender,
                      ),
                    )
                  : await _notifier.update(
                      UpdateStudentParams(
                        studentId: existing.id,
                        fullName: name,
                        birthYear: year,
                        gender: gender,
                      ),
                    );
              if (ok && mounted) {
                Navigator.pop(context);
                _showSnack(
                  existing == null ? '✓ Alumno creado' : '✓ Cambios guardados',
                  AppTheme.activeGreen,
                );
              } else if (mounted) {
                _showSnack(_state.error ?? 'Ocurrió un error', AppTheme.riskRed);
              }
            },
          );
        },
      ),
    );
  }

  void _confirmDeleteGroup(GroupEntity group) {
    final hasStudents = group.studentCount > 0;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar ${group.displayName}'),
        content: hasStudents
            ? Text(
                'Este grupo tiene ${group.studentCount} alumno${group.studentCount == 1 ? '' : 's'}. '
                'Mueve o elimina a los alumnos antes de borrar el grupo.',
              )
            : const Text('¿Eliminar este grupo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          if (!hasStudents)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final ok = await _notifier.deleteGroup(group.id);
                _showSnack(
                  ok ? '✓ Grupo eliminado' : (_state.error ?? 'No se pudo eliminar'),
                  ok ? AppTheme.activeGreen : AppTheme.riskRed,
                );
              },
              child: Text('Eliminar', style: TextStyle(color: AppTheme.riskRed)),
            ),
        ],
      ),
    );
  }

  void _confirmDeactivate(StudentEntity student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Desactivar alumno?'),
        content: Text(
          '${student.fullName} dejará de aparecer como activo y no se le podrán asignar '
          'nuevos tests. Su historial clínico y evaluaciones se conservan; puedes '
          'reactivarlo cuando quieras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await _notifier.delete(student.id);
              _showSnack(
                ok
                    ? '✓ Alumno desactivado'
                    : (_state.error ?? 'No se pudo desactivar'),
                ok ? AppTheme.activeGreen : AppTheme.riskRed,
              );
            },
            child: Text('Desactivar', style: TextStyle(color: AppTheme.riskRed)),
          ),
        ],
      ),
    );
  }

  void _confirmPermanentDelete(StudentEntity student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.delete_forever_rounded, color: AppTheme.riskRed, size: 22),
          const SizedBox(width: 8),
          const Text('Eliminar permanentemente'),
        ]),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Esta acción '),
              TextSpan(text: 'NO se puede deshacer', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.riskRed)),
              const TextSpan(text: '.\n\nSe eliminarán todos los datos de '),
              TextSpan(text: student.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const TextSpan(text: ': evaluaciones, sesiones, historial clínico y diagnósticos.\n\n¿Estás seguro?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.riskRed),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await _notifier.permanentDelete(student.id);
              _showSnack(
                ok ? '✓ ${student.fullName} eliminado permanentemente' : (_state.error ?? 'No se pudo eliminar'),
                ok ? AppTheme.activeGreen : AppTheme.riskRed,
              );
            },
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
  }

  void _activate(StudentEntity student) async {
    final ok = await _notifier.activate(student.id);
    _showSnack(
      ok ? '✓ ${student.fullName} reactivado' : (_state.error ?? 'No se pudo reactivar'),
      ok ? AppTheme.activeGreen : AppTheme.riskRed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentsViewModelProvider);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.hPad, 20, context.hPad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alumnos',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${state.totalCount} en total · ${state.activeCount} activos',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.mutedText),
                            ),
                          ],
                        ),
                      ),
                      const ThemeToggleButton(),
                      IconButton.filled(
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  StudentsSearchBar(onChanged: _notifier.search),
                  if (state.groups.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GroupFilterChips(
                      groups: state.groups,
                      selectedGroupId: state.groupFilter,
                      onSelected: _notifier.filterByGroup,
                      onDeleteGroup: _confirmDeleteGroup,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: state.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : state.error != null && state.students.isEmpty
                  ? _ErrorState(message: state.error!, onRetry: _notifier.loadStudents)
                  : state.students.isEmpty
                  ? StudentsEmptyState(onAdd: () => _openForm())
                  : RefreshIndicator(
                      onRefresh: _notifier.loadStudents,
                      color: AppTheme.primary,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          context.hPad,
                          0,
                          context.hPad,
                          90,
                        ),
                        itemCount: state.students.length,
                        itemBuilder: (context, i) {
                          final s = state.students[i];
                          return StudentListTile(
                            student: s,
                            onTap: () => context.push(
                              '/student/${s.id}',
                              extra: {'name': s.fullName},
                            ),
                            onEdit: () => _openForm(existing: s),
                            onDelete: () => _confirmDeactivate(s),
                            onActivate: () => _activate(s),
                            onPermanentDelete: () => _confirmPermanentDelete(s),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppTheme.riskRed.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}
