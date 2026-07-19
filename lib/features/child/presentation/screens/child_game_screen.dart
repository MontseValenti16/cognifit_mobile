import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../intervention/presentation/viewmodels/intervention_viewmodel.dart';
import '../../data/child_exercises.dart';
import '../widgets/child_game_widgets.dart';

/// Juego de discriminación visual para el niño.
/// Contenido basado en "Material de apoyo para la Dislexia" (Profra. J. González García).
///
/// El resultado de la partida se reporta a la ruta de intervención del alumno
/// (`/next-exercise`): antes el puntaje se quedaba en memoria y se perdía, así
/// que la ruta adaptativa —que sube de nivel con >90% de acierto y agrega apoyo
/// con <40%— nunca recibía datos y no avanzaba nunca.
class ChildGameScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ChildGameScreen({super.key, required this.studentId, required this.studentName});

  @override
  State<ChildGameScreen> createState() => _ChildGameScreenState();
}

class _ChildGameScreenState extends State<ChildGameScreen> {
  late List<ChildExercise> _exercises;
  int _sessionSeed = 0;
  int _current = 0;
  String? _selectedOption;
  late List<String> _currentOptions;
  int _score = 0;
  bool _gameOver = false;

  static const int _exerciseCount = 10;

  late final InterventionViewModel _intervention;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _sessionSeed = DateTime.now().millisecondsSinceEpoch;
    _exercises = pickExercises(count: _exerciseCount, seed: _sessionSeed);
    _buildOptions();
    // Se carga la ruta activa para saber en qué ejercicio va el alumno; si no
    // tiene ruta (sin diagnóstico todavía), el juego funciona igual: es
    // práctica libre y simplemente no hay nada que reportar.
    _intervention = ServiceLocator.instance.interventionViewModel();
    _intervention.load(widget.studentId);
  }

  /// Informa el desempeño a la ruta adaptativa una sola vez por partida.
  Future<void> _reportarDesempeno() async {
    if (_reported || _exercises.isEmpty) return;
    _reported = true;
    // El servicio de recomendación espera precisión entre 0 y 1.
    final accuracy = _score / _exercises.length;
    if (_intervention.current == null) return;   // sin ruta activa, nada que avanzar
    try {
      await _intervention.recordAndAdvance(widget.studentId, accuracy);
    } catch (_) {
      // El avance de ruta no debe romper la pantalla del niño.
    }
  }

  void _buildOptions() {
    if (_current < _exercises.length) {
      _currentOptions = _exercises[_current].shuffledOptions(_sessionSeed + _current);
    }
  }

  ChildExercise get _ex => _exercises[_current];

  void _onTap(String option) {
    if (_selectedOption != null) return;
    final isCorrect = option == _ex.oddOption;
    if (isCorrect) {
      TtsService.instance.speak('¡Muy bien!');
      _score++;
    }
    setState(() => _selectedOption = option);
  }

  void _next() {
    TtsService.instance.stop();
    if (_current >= _exercises.length - 1) {
      setState(() => _gameOver = true);
      _reportarDesempeno();
    } else {
      setState(() {
        _current++;
        _selectedOption = null;
        _buildOptions();
      });
    }
  }

  void _restart() {
    final newSeed = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _sessionSeed = newSeed;
      _exercises = pickExercises(count: _exerciseCount, seed: newSeed);
      _current = 0;
      _selectedOption = null;
      _score = 0;
      _gameOver = false;
      _reported = false;
      _buildOptions();
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(child: ChildGameCompleted(
          studentName: widget.studentName,
          correct: _score,
          total: _exercises.length,
          onPlayAgain: _restart,
          onFinish: () => Navigator.pop(context),
        )),
      );
    }

    final answered = _selectedOption != null;
    final isCorrect = _selectedOption == _ex.oddOption;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(child: Column(children: [
        ChildProgressBar(
          current: _current + (answered ? 1 : 0),
          total: _exercises.length,
          onClose: () => Navigator.pop(context),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),
            // Etiqueta de sección
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_ex.sectionLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primary, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            ),
            const SizedBox(height: 16),
            // Pregunta principal
            Text(_ex.question,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800, fontSize: 24, color: AppTheme.onSurface)),
            const SizedBox(height: 8),
            // Instrucción
            Text(_ex.instruction,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6B6880), fontSize: 14)),
            const SizedBox(height: 28),
            // Tarjetas de opciones
            OptionCardsRow(
              options: _currentOptions,
              correctAnswer: _ex.oddOption,
              selectedOption: _selectedOption,
              exerciseType: _ex.type,
              onTap: _onTap,
            ),
            const SizedBox(height: 24),
            // Retroalimentación
            if (answered)
              ChildFeedbackBanner(
                isCorrect: isCorrect,
                studentName: widget.studentName,
                explanation: _ex.explanation,
              ),
            const SizedBox(height: 12),
            // Botones auxiliares
            if (!answered)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _AuxButton(
                  icon: Icons.volume_up_rounded,
                  label: 'Escuchar',
                  color: AppTheme.tertiary,
                  onTap: () => TtsService.instance.speak(_ex.question),
                ),
                const SizedBox(width: 12),
                _AuxButton(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Pista',
                  color: AppTheme.pendingOrange,
                  onTap: () => TtsService.instance.speak(_ex.instruction),
                ),
              ]),
            const SizedBox(height: 80),
          ]),
        )),
        // Botón de siguiente fijo abajo
        if (answered)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? AppTheme.activeGreen : AppTheme.primary,
              ),
              child: Text(
                _current < _exercises.length - 1 ? 'Siguiente ejercicio →' : 'Ver mi resultado',
              ),
            ),
          ),
      ])),
    );
  }
}

class _AuxButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AuxButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
