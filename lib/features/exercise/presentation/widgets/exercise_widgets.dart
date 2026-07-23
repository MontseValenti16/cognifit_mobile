import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/text_format.dart';

class ExerciseProgressBar extends StatelessWidget {
  final double progress;
  final String moduleTitle;
  final VoidCallback onClose;

  const ExerciseProgressBar({super.key, required this.progress, required this.moduleTitle, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.close_rounded, size: 22), onPressed: onClose, color: AppTheme.onSurface, padding: EdgeInsets.zero),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: AppTheme.outline.withValues(alpha: 0.3), valueColor: AlwaysStoppedAnimation(AppTheme.primary)))),
          const SizedBox(width: 10),
          Text('${(progress * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 40),
          child: Text(moduleTitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.mutedText, letterSpacing: 0.5)))),
      ]),
    );
  }
}

/// Free-text response field — used when item_kind expects typed/spoken answer.
class ResponseTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool showMic;
  final bool isListening;
  final VoidCallback? onMicTap;
  final bool enabled;
  const ResponseTextField({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.showMic = false,
    this.isListening = false,
    this.onMicTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        controller: controller,
        enabled: enabled,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
        decoration: InputDecoration(
          hintText: isListening ? 'Escuchando...' : 'Escribe la respuesta...',
          filled: true, fillColor: AppTheme.cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.outline)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.primary, width: 2)),
          suffixIcon: showMic
              ? IconButton(
                  icon: Icon(isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: isListening ? AppTheme.riskRed : AppTheme.primary),
                  onPressed: enabled ? onMicTap : null,
                )
              : null,
        ),
        onSubmitted: (_) => onSubmit(),
      ),
    ]);
  }
}

/// Stimulus display card — shows the text the student must read/respond to.
class StimulusCard extends StatelessWidget {
  final String stimulusText;
  final String itemKind;
  final bool isPractice;
  final bool showSpeaker;
  final VoidCallback? onSpeak;
  const StimulusCard({
    super.key,
    required this.stimulusText,
    required this.itemKind,
    this.isPractice = false,
    this.showSpeaker = false,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4))),
      child: Column(children: [
        if (isPractice)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('Ítem de práctica', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.tertiary, fontWeight: FontWeight.w600)),
          ),
        Text(stimulusText, textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700, fontFamily: 'serif')),
        if (showSpeaker) ...[
          const SizedBox(height: 12),
          IconButton(
            icon: Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 28),
            onPressed: onSpeak,
            tooltip: 'Escuchar',
          ),
        ],
      ]),
    );
  }
}

/// Retroalimentación inmediata tras responder (HU-FL-12): se muestra
/// brevemente antes de avanzar al siguiente ítem cuando el ítem tiene
/// una respuesta esperada conocida.
class AnswerFeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  const AnswerFeedbackBanner({super.key, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppTheme.activeGreen : AppTheme.pendingOrange;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(isCorrect ? Icons.check_circle_rounded : Icons.refresh_rounded, color: color),
        const SizedBox(width: 10),
        Text(isCorrect ? '¡Muy bien!' : 'Sigamos practicando',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class ExerciseCompletedCard extends StatelessWidget {
  final String? plnSubtype;
  final String? plnSeverity;
  final String? riskLevel;
  final double? riskProbability;
  final VoidCallback onFinish;

  const ExerciseCompletedCard({
    super.key, this.plnSubtype, this.plnSeverity, this.riskLevel, this.riskProbability, required this.onFinish,
  });

  Color get _riskColor => switch (riskLevel) {
    'HIGH' => AppTheme.riskRed,
    'MEDIUM' => AppTheme.pendingOrange,
    _ => AppTheme.activeGreen,
  };


  @override
  Widget build(BuildContext context) {
    return Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: _riskColor.withValues(alpha: 0.1)),
          child: Icon(Icons.check_circle_rounded, color: _riskColor, size: 56)),
        const SizedBox(height: 24),
        Text('¡Sesión completada!', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('El diagnóstico se generó y se guardó en el perfil del alumno.',
          textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.mutedText)),
        const SizedBox(height: 24),
        if (plnSubtype != null) Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: _riskColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(18), border: Border.all(color: _riskColor.withValues(alpha: 0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Subtipo', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.mutedText)),
                Text(slugToLabel(plnSubtype!), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _riskColor, fontWeight: FontWeight.w700)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Severidad', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.mutedText)),
                Text(plnSeverity != null ? slugToLabel(plnSeverity!) : '-', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _riskColor, fontWeight: FontWeight.w700)),
              ]),
            ]),
            if (riskProbability != null) ...[
              const SizedBox(height: 14),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                value: riskProbability, minHeight: 8, backgroundColor: AppTheme.outline.withValues(alpha: 0.3), valueColor: AlwaysStoppedAnimation(_riskColor))),
              const SizedBox(height: 6),
              Text('Riesgo: $riskLevel · ${(riskProbability! * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _riskColor, fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
        const SizedBox(height: 28),
        ElevatedButton(onPressed: onFinish, child: const Text('Volver al dashboard')),
      ]),
    ));
  }
}

/// Respuesta de opción múltiple para ítems de discriminación visual (M10_VD).
///
/// Esos ítems traen el estímulo como opciones separadas por pipe
/// ("b|b|d|b") y la respuesta esperada es la opción distinta ("d"). Sin este
/// widget el niño veía el texto crudo "b|b|d|b" y un campo de texto, así que
/// el módulo era inusable: por eso estuvo fuera de la batería aunque su
/// migración, su test y sus 21 ítems existían desde hace tiempo.
class MultipleChoiceAnswer extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onSelect;
  final String? selected;
  final bool enabled;

  const MultipleChoiceAnswer({
    super.key,
    required this.options,
    required this.onSelect,
    this.selected,
    this.enabled = true,
  });

  /// "b|b|d|b" -> ["b","b","d","b"]. Devuelve vacío si no es formato de opciones.
  static List<String> parseOptions(String stimulusText) {
    if (!stimulusText.contains('|')) return const [];
    return stimulusText
        .split('|')
        .map((o) => o.trim())
        .where((o) => o.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: [
        for (var i = 0; i < options.length; i++)
          _OptionButton(
            // La posición se muestra al niño, no el índice: dos opciones pueden
            // tener el mismo texto ("b|b|d|b") y deben ser tocables por separado.
            label: options[i],
            isSelected: selected == options[i],
            enabled: enabled,
            onTap: () => onSelect(options[i]),
          ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;
  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Opción $label',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.12) : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.outline.withValues(alpha: 0.5),
              width: isSelected ? 2.5 : 1.2,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'serif',
                  color: isSelected ? AppTheme.primary : null,
                ),
          ),
        ),
      ),
    );
  }
}
