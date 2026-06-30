import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/screening_entity.dart';

/// One question card from the 8-item teacher questionnaire (PRODISLEX based).
class TeacherQuestionCard extends StatelessWidget {
  final TeacherItemEntity item;
  final int index;
  final double? selectedValue;
  final ValueChanged<double> onSelect;

  const TeacherQuestionCard({
    super.key, required this.item, required this.index,
    required this.selectedValue, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final answered = selectedValue != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: answered ? AppTheme.primary.withOpacity(0.4) : AppTheme.outline.withOpacity(0.5), width: answered ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: answered ? AppTheme.primary : AppTheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text('${index + 1}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: answered ? Colors.white : AppTheme.primary, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(item.prompt, style: Theme.of(context).textTheme.bodyLarge)),
        ]),
        if (item.sourceNote != null) ...[
          const SizedBox(height: 6),
          Padding(padding: const EdgeInsets.only(left: 36), child: Text('Fuente: ${item.sourceNote}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF9E9CAD)))),
        ],
        const SizedBox(height: 14),
        Row(children: item.scale.entries.map((e) {
          final selected = selectedValue == e.value;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onSelect(e.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? _colorFor(e.value) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? _colorFor(e.value) : AppTheme.outline, width: selected ? 2 : 1),
                ),
                child: Text(e.key, textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? Colors.white : AppTheme.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
              ),
            ),
          ));
        }).toList()),
      ]),
    );
  }

  Color _colorFor(double v) {
    if (v == 0) return AppTheme.activeGreen;
    if (v == 0.5) return AppTheme.pendingOrange;
    return AppTheme.riskRed;
  }
}

/// Progress header for the questionnaire (X of 8 answered)
class QuestionnaireProgress extends StatelessWidget {
  final int answered;
  final int total;
  const QuestionnaireProgress({super.key, required this.answered, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : answered / total;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$answered de $total respondidas', style: Theme.of(context).textTheme.bodyMedium),
        Text('${(pct * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: AppTheme.outline.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation(AppTheme.primary))),
    ]);
  }
}

/// Result card shown after teacher-results comes back: score + risk flags
class TeacherResultCard extends StatelessWidget {
  final TeacherResultEntity result;
  const TeacherResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.score >= 60 ? AppTheme.riskRed : result.score >= 30 ? AppTheme.pendingOrange : AppTheme.activeGreen;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.insights_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Text('PUNTAJE DE TAMIZAJE', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(result.score.toStringAsFixed(1), style: Theme.of(context).textTheme.displayMedium?.copyWith(color: color, fontWeight: FontWeight.w800)),
          Padding(padding: const EdgeInsets.only(bottom: 6, left: 4), child: Text('/ 100', style: Theme.of(context).textTheme.bodyMedium)),
        ]),
        const SizedBox(height: 12),
        if (result.riskFlags.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: result.riskFlags.map((f) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Text('${f.flag} · ${f.level}', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600)),
        )).toList()),
        if (result.enabledModuleCodes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Módulos recomendados: ${result.enabledModuleCodes.length}', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ]),
    );
  }
}
