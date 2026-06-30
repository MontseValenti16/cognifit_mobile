import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../viewmodels/exercise_viewmodel.dart';
import '../widgets/exercise_widgets.dart';

/// Renders one screening session: GET items, collects responses,
/// then submits + diagnoses when the last item is answered.
class ExerciseScreen extends StatefulWidget {
  final String sessionId;
  final String moduleTitle;

  const ExerciseScreen({super.key, required this.sessionId, required this.moduleTitle});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late final ExerciseViewModel _vm;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.exerciseViewModel;
    _vm.addListener(_rebuild);
    _vm.loadSession(widget.sessionId);
  }

  @override
  void dispose() { _vm.removeListener(_rebuild); _controller.dispose(); super.dispose(); }
  void _rebuild() { if (mounted) setState(() {}); }

  void _confirmClose() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('¿Salir de la sesión?'),
      content: const Text('Las respuestas no enviadas se perderán.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Continuar')),
        TextButton(
          onPressed: () { Navigator.pop(context); context.go(AppRouter.dashboard); _vm.reset(); },
          child: Text('Salir', style: TextStyle(color: AppTheme.riskRed)),
        ),
      ],
    ));
  }

  void _submitCurrent() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _vm.answer(text, captureModality: 'teclado');
    _controller.clear();
    _vm.nextItem();
  }

  @override
  Widget build(BuildContext context) {
    if (_vm.isLoading) {
      return const Scaffold(backgroundColor: AppTheme.surface, body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    }

    if (_vm.status == ExerciseStatus.error) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(child: Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.riskRed),
            const SizedBox(height: 12),
            Text(_vm.error ?? 'Ocurrió un error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () { context.go(AppRouter.dashboard); _vm.reset(); }, child: const Text('Volver')),
          ]),
        ))),
      );
    }

    if (_vm.isCompleted) {
      final d = _vm.diagnosis;
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(child: ExerciseCompletedCard(
          plnSubtype: d?.plnSubtype, plnSeverity: d?.plnSeverity,
          riskLevel: d?.riskLevel, riskProbability: d?.riskProbability,
          onFinish: () { context.go(AppRouter.dashboard); _vm.reset(); },
        )),
      );
    }

    if (_vm.isSubmitting) {
      return const Scaffold(backgroundColor: AppTheme.surface, body: Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 16),
          Text('Generando diagnóstico...'),
        ]),
      )));
    }

    final item = _vm.current;
    if (item == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(child: Column(children: [
        ExerciseProgressBar(progress: _vm.progress, moduleTitle: widget.moduleTitle, onClose: _confirmClose),
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.hPad),
          child: Column(children: [
            const SizedBox(height: 24),
            StimulusCard(stimulusText: item.stimulusText, itemKind: item.itemKind, isPractice: item.isPractice),
            const SizedBox(height: 24),
            ResponseTextField(controller: _controller, onSubmit: _submitCurrent),
            const SizedBox(height: 8),
            Text('Modalidad: ${item.inputModes.join(", ")}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD))),
          ]),
        )),
        Padding(
          padding: EdgeInsets.fromLTRB(context.hPad, 8, context.hPad, 24),
          child: ElevatedButton(
            onPressed: _submitCurrent,
            child: Text(_vm.currentIndex < _vm.totalItems - 1 ? 'Siguiente →' : 'Finalizar sesión'),
          ),
        ),
      ])),
    );
  }
}
