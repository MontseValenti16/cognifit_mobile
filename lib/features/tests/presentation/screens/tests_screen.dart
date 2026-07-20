import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../viewmodels/tests_viewmodel.dart';
import '../widgets/teacher_questionnaire_widgets.dart';

/// Entry point for SCREENING flow:
/// 1) Pick a student  2) Answer 8-question questionnaire  3) Submit -> score
/// 4) Assign battery  5) Open first session -> navigate to ExerciseScreen
class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});
  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  late final TestsViewModel _vm;
  int _step = 0; // 0 = pick student, 1 = questionnaire, 2 = result

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.testsViewModel;
    _vm.addListener(_rebuild);
    _vm.reset();
    _vm.loadTeacherItemsAndCatalog();
    ServiceLocator.instance.studentsViewModel.loadStudents();
  }

  @override
  void dispose() { _vm.removeListener(_rebuild); super.dispose(); }
  void _rebuild() { if (mounted) setState(() {}); }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _submitAndAssign() async {
    final okSubmit = await _vm.submitQuestionnaire();
    if (!okSubmit) { _showSnack(_vm.error ?? 'Error al enviar', AppTheme.riskRed); return; }
    setState(() => _step = 2);
    final okAssign = await _vm.assignBattery();
    if (!okAssign) { _showSnack(_vm.error ?? 'Error al asignar batería', AppTheme.riskRed); }
  }

  Future<void> _startFirstModule() async {
    final session = await _vm.openFirstSession();
    if (session == null) { _showSnack(_vm.error ?? 'No se pudo iniciar la sesión', AppTheme.riskRed); return; }
    if (!mounted) return;
    final assignment = _vm.assignmentResult!.assignments.first;
    context.push('/exercise-session/${session.id}', extra: {
      'moduleTitle': _vm.moduleName(assignment.moduleCode),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(context.hPad, 20, context.hPad, 12),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () {
                if (_step > 0) { setState(() => _step--); _vm.reset(); } else { Navigator.pop(context); }
              },
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 4),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_titleFor(_step), style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(_subtitleFor(_step), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B6880))),
            ])),
          ]),
        ),
        Expanded(child: _vm.isLoading ? const Center(child: CircularProgressIndicator(color: AppTheme.primary)) : _buildStep(context)),
      ])),
    );
  }

  String _titleFor(int step) => switch (step) {
    0 => 'Batería de Tests',
    1 => 'Cuestionario docente',
    _ => 'Resultado del tamizaje',
  };
  String _subtitleFor(int step) => switch (step) {
    0 => 'Selecciona un alumno para iniciar el tamizaje',
    1 => 'Responde las 8 preguntas según observación reciente',
    _ => 'Puntaje y batería sugerida',
  };

  Widget _buildStep(BuildContext context) {
    if (_step == 0) return _StudentPickerStep(onPick: (s) { _vm.selectStudentAndLoad(s); setState(() => _step = 1); });
    if (_step == 1) return _QuestionnaireStep(vm: _vm, onSubmit: _submitAndAssign);
    return _ResultStep(vm: _vm, onStart: _startFirstModule, onAssignLater: () {
      _showSnack('✓ Batería asignada. El alumno aparecerá con test pendiente.', AppTheme.activeGreen);
      Navigator.pop(context);
    });
  }
}

class _StudentPickerStep extends StatelessWidget {
  final ValueChanged<StudentEntity> onPick;
  const _StudentPickerStep({required this.onPick});

  @override
  Widget build(BuildContext context) {
    final sVm = ServiceLocator.instance.studentsViewModel;
    return ListenableBuilder(
      listenable: sVm,
      builder: (context, _) {
        if (sVm.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        if (sVm.students.isEmpty) {
          return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(
            'No hay alumnos registrados. Agrega uno desde "Alumnos" primero.',
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium)));
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 8),
          itemCount: sVm.students.length,
          itemBuilder: (context, i) {
            final s = sVm.students[i];
            return GestureDetector(
              onTap: () => onPick(s),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.outline.withOpacity(0.5))),
                child: Row(children: [
                  CircleAvatar(backgroundColor: AppTheme.primaryContainer, child: Text(s.fullName.substring(0,1), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 14),
                  Expanded(child: Text(s.fullName, style: Theme.of(context).textTheme.titleMedium)),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFADA9B9)),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}

class _QuestionnaireStep extends StatelessWidget {
  final TestsViewModel vm;
  final VoidCallback onSubmit;
  const _QuestionnaireStep({required this.vm, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: context.hPad),
        child: QuestionnaireProgress(answered: vm.answers.length, total: vm.teacherItems.length),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(context.hPad, 0, context.hPad, 100),
          itemCount: vm.teacherItems.length,
          itemBuilder: (context, i) {
            final item = vm.teacherItems[i];
            return TeacherQuestionCard(
              item: item, index: i,
              selectedValue: vm.answers[item.itemCode],
              onSelect: (v) => vm.answerQuestion(item.itemCode, v),
            );
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(context.hPad, 8, context.hPad, 20),
        child: ElevatedButton(
          onPressed: vm.questionnaireComplete && !vm.isSubmitting ? onSubmit : null,
          child: vm.isSubmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Enviar cuestionario'),
        ),
      ),
    ]);
  }
}

class _ResultStep extends StatelessWidget {
  final TestsViewModel vm;
  final VoidCallback onStart;
  final VoidCallback onAssignLater;
  const _ResultStep({required this.vm, required this.onStart, required this.onAssignLater});

  @override
  Widget build(BuildContext context) {
    if (vm.teacherResult == null) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TeacherResultCard(result: vm.teacherResult!),
        const SizedBox(height: 20),
        if (vm.isSubmitting) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppTheme.primary)))
        else if (vm.assignmentResult != null) ...[
          Text('BATERÍA ASIGNADA', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700, color: const Color(0xFF9E9CAD))),
          const SizedBox(height: 10),
          ...vm.assignmentResult!.assignments.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.outline.withOpacity(0.5))),
            child: Row(children: [
              const Icon(Icons.assignment_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(vm.moduleName(a.moduleCode), style: Theme.of(context).textTheme.bodyMedium)),
              Text(a.status, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.pendingOrange)),
            ]),
          )),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onStart, child: const Text('Iniciar primer módulo ahora')),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onAssignLater, child: const Text('Asignar para después')),
        ],
      ]),
    );
  }
}
