import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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
            child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: AppTheme.outline.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation(AppTheme.primary)))),
          const SizedBox(width: 10),
          Text('${(progress * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 40),
          child: Text(moduleTitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF9E9CAD), letterSpacing: 0.5)))),
      ]),
    );
  }
}

/// Free-text response field — used when item_kind expects typed/spoken answer.
class ResponseTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  const ResponseTextField({super.key, required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
        decoration: InputDecoration(
          hintText: 'Escribe la respuesta...',
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.outline)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
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
  const StimulusCard({super.key, required this.stimulusText, required this.itemKind, this.isPractice = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.outline.withOpacity(0.4))),
      child: Column(children: [
        if (isPractice)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.tertiary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text('Ítem de práctica', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.tertiary, fontWeight: FontWeight.w600)),
          ),
        Text(stimulusText, textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700, fontFamily: 'serif')),
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
        Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: _riskColor.withOpacity(0.1)),
          child: Icon(Icons.check_circle_rounded, color: _riskColor, size: 56)),
        const SizedBox(height: 24),
        Text('¡Sesión completada!', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('El diagnóstico se generó y se guardó en el perfil del alumno.',
          textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF6B6880))),
        const SizedBox(height: 24),
        if (plnSubtype != null) Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: _riskColor.withOpacity(0.06), borderRadius: BorderRadius.circular(18), border: Border.all(color: _riskColor.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Subtipo', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF9E9CAD))),
                Text(plnSubtype!, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _riskColor, fontWeight: FontWeight.w700)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Severidad', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF9E9CAD))),
                Text(plnSeverity ?? '-', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _riskColor, fontWeight: FontWeight.w700)),
              ]),
            ]),
            if (riskProbability != null) ...[
              const SizedBox(height: 14),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                value: riskProbability, minHeight: 8, backgroundColor: AppTheme.outline.withOpacity(0.3), valueColor: AlwaysStoppedAnimation(_riskColor))),
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
