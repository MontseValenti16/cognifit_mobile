import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/child_exercises.dart';

/// Barra de progreso estilo niño: colorida, con estrella y contador.
class ChildProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback onClose;

  const ChildProgressBar({
    super.key,
    required this.current,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: onClose,
          color: AppTheme.onSurface,
          padding: EdgeInsets.zero,
        ),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppTheme.outline.withValues(alpha: 0.25),
            valueColor: AlwaysStoppedAnimation(
              HSLColor.fromColor(AppTheme.primary).withLightness(0.55).toColor(),
            ),
          ),
        )),
        const SizedBox(width: 10),
        Text('$current/$total',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }
}

/// Cuatro tarjetas de opción grande para el niño — el niño toca la diferente.

/// Banner de retroalimentación inmediata — en verde o rojo.
class ChildFeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final String studentName;
  final String explanation;

  const ChildFeedbackBanner({
    super.key,
    required this.isCorrect,
    required this.studentName,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppTheme.activeGreen : AppTheme.riskRed;
    final icon = isCorrect ? Icons.star_rounded : Icons.refresh_rounded;
    final title = isCorrect ? '¡Muy bien, $studentName!' : '¡Casi lo logras!';

    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 250),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.09),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha:0.35), width: 1.5),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(explanation, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color.withValues(alpha:0.85), fontSize: 13)),
          ])),
        ]),
      ),
    );
  }
}

/// Pantalla de final del juego — muestra estrellas según el puntaje.
class ChildGameCompleted extends StatelessWidget {
  final String studentName;
  final int correct;
  final int total;
  final VoidCallback onPlayAgain;
  final VoidCallback onFinish;

  const ChildGameCompleted({
    super.key,
    required this.studentName,
    required this.correct,
    required this.total,
    required this.onPlayAgain,
    required this.onFinish,
  });

  int get _stars => correct >= total ? 3 : correct >= (total * 0.7).ceil() ? 2 : correct >= (total * 0.4).ceil() ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : correct / total;
    final color = pct >= 0.8 ? AppTheme.activeGreen : pct >= 0.5 ? AppTheme.pendingOrange : AppTheme.riskRed;
    return Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('⭐' * _stars + '☆' * (3 - _stars), style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('¡Terminaste, $studentName!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('$correct de $total correctas', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
        const SizedBox(height: 24),
        ClipRRect(borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: pct, minHeight: 12,
            backgroundColor: AppTheme.outline.withValues(alpha:0.25),
            valueColor: AlwaysStoppedAnimation(color),
          )),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: onPlayAgain,
          icon: const Icon(Icons.replay_rounded, size: 20),
          label: const Text('Jugar de nuevo'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiary),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onFinish, child: const Text('Terminar')),
      ]),
    ));
  }
}

/// Badge de logro para el panel de inicio del niño.
