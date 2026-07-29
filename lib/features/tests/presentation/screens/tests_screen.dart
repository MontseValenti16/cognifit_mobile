import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/presentation/viewmodels/students_viewmodel.dart';
import '../viewmodels/tests_viewmodel.dart';
import '../widgets/teacher_questionnaire_widgets.dart';

/// Entry point for SCREENING flow:
/// 1) Pick a student  2) Answer 8-question questionnaire  3) Submit -> score
/// 4) Assign battery  5) Open first session -> navigate to ExerciseScreen
class TestsScreen extends ConsumerStatefulWidget {
  const TestsScreen({super.key});
  @override
  ConsumerState<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends ConsumerState<TestsScreen> {
  TestsState get _state => ref.read(testsViewModelProvider);
  TestsNotifier get _notifier => ref.read(testsViewModelProvider.notifier);
  int _step = 0; // 0 = pick student, 1 = questionnaire, 2 = result

  @override
  void initState() {
    super.initState();
    // Ver nota en dashboard_screen: modificar un provider desde initState
    // ocurre durante el build y Riverpod lo rechaza.
    Future(() {
      if (!mounted) return;
      _notifier.reset();
      _notifier.loadTeacherItemsAndCatalog();
      ref.read(studentsViewModelProvider.notifier).loadStudents();
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _submitAndAssign() async {
    final okSubmit = await _notifier.submitQuestionnaire();
    if (!okSubmit) { _showSnack(_state.error ?? 'Error al enviar', AppTheme.riskRed); return; }
    setState(() => _step = 2);
    final okAssign = await _notifier.assignBattery();
    if (!okAssign) { _showSnack(_state.error ?? 'Error al asignar batería', AppTheme.riskRed); }
  }

  Future<void> _startFirstModule() async {
    final session = await _notifier.openFirstSession();
    if (session == null) { _showSnack(_state.error ?? 'No se pudo iniciar la sesión', AppTheme.riskRed); return; }
    if (!mounted) return;
    final assignment = _state.assignmentResult!.assignments.first;
    context.push('/exercise-session/${session.id}', extra: {
      'moduleTitle': _state.moduleName(assignment.moduleCode),
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testsViewModelProvider);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(context.hPad, 20, context.hPad, 12),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () {
                if (_step > 0) { setState(() => _step--); _notifier.reset(); } else { Navigator.pop(context); }
              },
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 4),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_titleFor(_step), style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(_subtitleFor(_step), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText)),
            ])),
            const ThemeToggleButton(),
          ]),
        ),
        Expanded(child: state.isLoading ? Center(child: CircularProgressIndicator(color: AppTheme.primary)) : _buildStep(context, state)),
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
    1 => 'Responde las preguntas según observación reciente',
    _ => 'Puntaje y batería sugerida',
  };

  Widget _buildStep(BuildContext context, TestsState state) {
    if (_step == 0) return _StudentPickerStep(onPick: (s) { _notifier.selectStudentAndLoad(s); setState(() => _step = 1); });
    if (_step == 1) return _QuestionnaireStep(state: state, onAnswer: _notifier.answerQuestion, onSubmit: _submitAndAssign);
    return _ResultStep(state: state, onStart: _startFirstModule, onAssignLater: () {
      _showSnack('✓ Batería asignada. El alumno aparecerá con test pendiente.', AppTheme.activeGreen);
      Navigator.pop(context);
    });
  }
}

class _StudentPickerStep extends ConsumerWidget {
  final ValueChanged<StudentEntity> onPick;
  const _StudentPickerStep({required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sVm = ref.watch(studentsViewModelProvider);
    if (sVm.isLoading) return Center(child: CircularProgressIndicator(color: AppTheme.primary));
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
            decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5))),
            child: Row(children: [
              CircleAvatar(backgroundColor: AppTheme.primaryContainer, child: Text(s.fullName.substring(0,1), style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
              const SizedBox(width: 14),
              Expanded(child: Text(s.fullName, style: Theme.of(context).textTheme.titleMedium)),
              Icon(Icons.chevron_right_rounded, color: AppTheme.mutedText),
            ]),
          ),
        );
      },
    );
  }
}

class _QuestionnaireStep extends StatelessWidget {
  final TestsState state;
  final void Function(String itemCode, double value) onAnswer;
  final VoidCallback onSubmit;
  const _QuestionnaireStep({required this.state, required this.onAnswer, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: context.hPad),
        child: QuestionnaireProgress(answered: state.answers.length, total: state.teacherItems.length),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: ListView(
          padding: EdgeInsets.fromLTRB(context.hPad, 0, context.hPad, 100),
          children: [
            for (final entry in state.itemsPorCategoria.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8),
                child: Text(
                  switch (entry.key) {
                    'HISTORIA_CLINICA' => 'Antes de empezar: descartar otras causas',
                    'DISCREPANCIA' => '¿La dificultad es inesperada?',
                    _ => 'Señales en la lectura y la escritura',
                  },
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700, color: AppTheme.primary),
                ),
              ),
              for (final item in entry.value)
                TeacherQuestionCard(
                  item: item,
                  index: state.teacherItems.indexOf(item),
                  selectedValue: state.answers[item.itemCode],
                  onSelect: (v) => onAnswer(item.itemCode, v),
                ),
            ],
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(context.hPad, 8, context.hPad, 20),
        child: ElevatedButton(
          onPressed: state.questionnaireComplete && !state.isSubmitting ? onSubmit : null,
          child: state.isSubmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Enviar cuestionario'),
        ),
      ),
    ]);
  }
}

class _ResultStep extends StatelessWidget {
  final TestsState state;
  final VoidCallback onStart;
  final VoidCallback onAssignLater;
  const _ResultStep({required this.state, required this.onStart, required this.onAssignLater});

  @override
  Widget build(BuildContext context) {
    if (state.teacherResult == null) return Center(child: CircularProgressIndicator(color: AppTheme.primary));
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TeacherResultCard(result: state.teacherResult!),
        if (state.teacherResult?.requiereDescartarSensorial ?? false)
          const SensorialAlertBanner(),
        const SizedBox(height: 20),
        if (state.isSubmitting) Center(child: Padding(padding: const EdgeInsets.all(24), child: CircularProgressIndicator(color: AppTheme.primary)))
        else if (state.assignmentResult != null) ...[
          Text('BATERÍA ASIGNADA', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700, color: AppTheme.mutedText)),
          const SizedBox(height: 10),
          ...state.assignmentResult!.assignments.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5))),
            child: Row(children: [
              Icon(Icons.assignment_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(state.moduleName(a.moduleCode), style: Theme.of(context).textTheme.bodyMedium)),
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
