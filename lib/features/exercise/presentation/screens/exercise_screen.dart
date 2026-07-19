import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/offline/sync_service.dart';
import '../../../../core/services/stt_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/offline_banner.dart';
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
  String _captureModality = 'teclado';
  double? _sttConfidence;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _vm = ServiceLocator.instance.exerciseViewModel;
    _vm.addListener(_rebuild);
    _vm.loadSession(widget.sessionId);
    SyncService.instance.syncPending(ServiceLocator.instance.apiClient);
  }

  @override
  void dispose() {
    _vm.removeListener(_rebuild);
    _controller.dispose();
    TtsService.instance.stop();
    SttService.instance.stop();
    super.dispose();
  }
  void _rebuild() { if (mounted) setState(() {}); }

  bool _supportsMode(String mode) =>
      _vm.current?.inputModes.any((m) => m.toUpperCase().contains(mode)) ?? false;

  Future<void> _startListening() async {
    setState(() => _isListening = true);
    final result = await SttService.instance.listenOnce();
    if (!mounted) return;
    setState(() => _isListening = false);
    if (result != null && result.text.trim().isNotEmpty) {
      _controller.text = result.text.trim();
      _captureModality = 'voz';
      _sttConfidence = result.confidence;
    }
  }

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
    if (_vm.lastAnswerCorrect != null) return; // esperando avance tras feedback
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _vm.answer(text, captureModality: _captureModality, sttConfidence: _sttConfidence);
    _controller.clear();
    _captureModality = 'teclado';
    _sttConfidence = null;

    _afterAnswer();
  }

  /// Retroalimentación + avance. Compartido entre la respuesta escrita y la
  /// de opción múltiple para que ambas se comporten igual.
  void _afterAnswer() {
    if (_vm.lastAnswerCorrect != null) {
      TtsService.instance.speak(_vm.lastAnswerCorrect! ? '¡Muy bien!' : 'Sigamos practicando');
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        _vm.nextItem();
      });
    } else {
      _vm.nextItem();
    }
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
    if (item == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(child: Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.inbox_rounded, size: 56, color: Color(0xFFADA9B9)),
            const SizedBox(height: 16),
            const Text('Esta sesión no tiene ítems configurados.\nContacta al administrador.',
              textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () { context.go(AppRouter.dashboard); _vm.reset(); },
              child: const Text('Volver'),
            ),
          ]),
        ))),
      );
    }

    final waitingFeedback = _vm.lastAnswerCorrect != null;
    final showSpeaker = _supportsMode('TTS');
    final showMic = _supportsMode('STT');
    final opciones = MultipleChoiceAnswer.parseOptions(item.stimulusText);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(child: Column(children: [
        const OfflineBanner(),
        ExerciseProgressBar(progress: _vm.progress, moduleTitle: widget.moduleTitle, onClose: _confirmClose),
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.hPad),
          child: Column(children: [
            const SizedBox(height: 24),
            // Los ítems de discriminación visual traen las opciones en el
            // propio estímulo ("b|b|d|b"): se muestran como botones y no
            // como texto, que era lo que hacía inusable ese módulo.
            if (opciones.isNotEmpty)
              StimulusCard(
                stimulusText: '¿Cuál es diferente?',
                itemKind: item.itemKind,
                isPractice: item.isPractice,
              )
            else
              StimulusCard(
                stimulusText: item.stimulusText,
                itemKind: item.itemKind,
                isPractice: item.isPractice,
                showSpeaker: showSpeaker,
                onSpeak: () => TtsService.instance.speak(item.stimulusText),
              ),
            const SizedBox(height: 24),
            if (opciones.isNotEmpty)
              MultipleChoiceAnswer(
                options: opciones,
                selected: _vm.selectedAnswer,
                enabled: !waitingFeedback,
                onSelect: (opcion) {
                  _vm.answer(opcion, captureModality: 'tactil');
                  _afterAnswer();
                },
              )
            else
              ResponseTextField(
                controller: _controller,
                onSubmit: _submitCurrent,
                showMic: showMic,
                isListening: _isListening,
                onMicTap: _startListening,
                enabled: !waitingFeedback,
              ),
            const SizedBox(height: 8),
            Text('Modalidad: ${item.inputModes.join(", ")}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD))),
            if (waitingFeedback) AnswerFeedbackBanner(isCorrect: _vm.lastAnswerCorrect!),
          ]),
        )),
        Padding(
          padding: EdgeInsets.fromLTRB(context.hPad, 8, context.hPad, 24),
          child: ElevatedButton(
            onPressed: waitingFeedback ? null : _submitCurrent,
            child: Text(_vm.currentIndex < _vm.totalItems - 1 ? 'Siguiente →' : 'Finalizar sesión'),
          ),
        ),
      ])),
    );
  }
}
