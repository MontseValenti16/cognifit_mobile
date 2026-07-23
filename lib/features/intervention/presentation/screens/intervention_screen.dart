import 'package:flutter/material.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/choice_player.dart';
import '../widgets/comprehension_player.dart';
import '../widgets/dictation_player.dart';
import '../widgets/naming_player.dart';
import '../widgets/reading_player.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../viewmodels/intervention_viewmodel.dart';

class InterventionScreen extends StatefulWidget {
  final InterventionViewModel vm;
  final String studentId;
  final String studentName;

  const InterventionScreen({
    super.key,
    required this.vm,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<InterventionScreen> createState() => _InterventionScreenState();
}

class _InterventionScreenState extends State<InterventionScreen> {
  @override
  void initState() {
    super.initState();
    widget.vm.addListener(_rebuild);
    widget.vm.load(widget.studentId);
  }

  @override
  void dispose() {
    widget.vm.removeListener(_rebuild);
    TtsService.instance.stop();
    widget.vm.reset();
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  /// Elige el reproductor según lo que trae el ejercicio. Devuelve null para
  /// los que todavía no tienen uno (voz y trazo), que siguen con calificación
  /// manual en vez de fingir una medición que no se hizo.
  Widget? _reproductor(dynamic exercise) {
    final texto = exercise.texto as String?;
    final hayTexto = texto != null && texto.trim().isNotEmpty;
    final items = (exercise.items as List).cast<Map<String, dynamic>>();

    // Comprensión: es el único caso que trae texto Y preguntas a la vez, así
    // que se resuelve ANTES que la lectura — si no, caería en ReadingPlayer y
    // las preguntas no se mostrarían nunca.
    if (hayTexto && items.isNotEmpty) {
      final preguntas =
          items.map(ChoiceQuestion.fromItem).whereType<ChoiceQuestion>().toList();
      if (preguntas.isNotEmpty) {
        return ComprehensionPlayer(
          texto: texto,
          preguntas: preguntas,
          usaTts: exercise.usaTts as bool,
          autoevaluacion: exercise.autoevaluacion as bool? ?? false,
          metaPalabrasPorMinuto: exercise.metaPalabrasPorMinuto as int?,
          onFinish: (accuracy, _, __, ___) => _rate(accuracy),
        );
      }
    }

    // Denominación rápida: rejilla + cronómetro. La medida es el tiempo total
    // de nombrar las 40 casillas, así que no hace falta reconocimiento de voz
    // —que era lo que tenía estos tres ejercicios sin jugarse.
    final grid = (exercise.grid as List).cast<String>();
    if (grid.isNotEmpty) {
      final subtipo = exercise.subtipo as String;
      return NamingPlayer(
        grid: grid,
        columnas: exercise.gridColumnas as int,
        kind: switch (subtipo) {
          'colores' => NamingKind.colores,
          'objetos' => NamingKind.objetos,
          _ => NamingKind.letras,
        },
        paleta: (exercise.paleta as Map<String, String>).map(
          (k, v) => MapEntry(k, _colorDeHex(v)),
        ),
        iconos: exercise.iconos as Map<String, String>,
        onFinish: (accuracy, _) => _rate(accuracy),
      );
    }

    if (hayTexto) {
      return ReadingPlayer(
        texto: texto,
        instruccion: exercise.instruccion as String,
        usaTts: exercise.usaTts as bool,
        metaPalabrasPorMinuto: exercise.metaPalabrasPorMinuto as int?,
        repeticiones: exercise.repeticiones as int?,
        onFinish: (accuracy, _) => _rate(accuracy),
      );
    }

    // Dictado: el ítem solo trae {target}; la app lo dicta y el alumno escribe.
    if (exercise.modalidad == 'teclado_tts') {
      final targets = items
          .map((i) => (i['target'] ?? '').toString())
          .where((t) => t.isNotEmpty)
          .toList();
      if (targets.isNotEmpty) {
        return DictationPlayer(
          targets: targets,
          onFinish: (accuracy, _, __) => _rate(accuracy),
        );
      }
    }

    final preguntas = items
        .map(ChoiceQuestion.fromItem)
        .whereType<ChoiceQuestion>()
        .toList();
    if (preguntas.isNotEmpty) {
      return ChoicePlayer(
        preguntas: preguntas,
        usaTts: exercise.usaTts as bool,
        onFinish: (accuracy, _, __) => _rate(accuracy),
      );
    }
    return null;
  }

  /// "#E53935" → Color. Si el banco trae un valor raro se cae a gris en vez
  /// de reventar la pantalla por un color mal escrito.
  static Color _colorDeHex(String hex) {
    final limpio = hex.replaceFirst('#', '');
    final v = int.tryParse(limpio, radix: 16);
    if (v == null || limpio.length != 6) return Colors.grey;
    return Color(0xFF000000 | v);
  }

  void _rate(double accuracy) =>
      widget.vm.recordAndAdvance(widget.studentId, accuracy);

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Intervención', style: Theme.of(context).textTheme.titleLarge),
          Text(widget.studentName, style: Theme.of(context).textTheme.bodyMedium),
        ]),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(child: _body(context, vm)),
    );
  }

  Widget _body(BuildContext context, InterventionViewModel vm) {
    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (vm.status == InterventionStatus.noPath) {
      return _centeredMessage(context,
        icon: Icons.route_rounded, color: AppTheme.pendingOrange,
        title: 'Sin ruta activa',
        body: 'Este alumno aún no tiene una ruta de intervención asignada. Ejecuta un diagnóstico primero.',
      );
    }
    if (vm.status == InterventionStatus.error) {
      return _centeredMessage(context,
        icon: Icons.error_outline_rounded, color: AppTheme.riskRed,
        title: 'Error',
        body: vm.error ?? 'Error desconocido',
        action: TextButton(onPressed: () => vm.load(widget.studentId), child: const Text('Reintentar')),
      );
    }
    if (vm.status == InterventionStatus.complete) {
      return _centeredMessage(context,
        icon: Icons.celebration_rounded, color: AppTheme.activeGreen,
        title: '¡Ruta completada!',
        body: 'El alumno ha terminado todos los ejercicios de esta ruta de intervención.',
        action: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Volver al perfil')),
      );
    }

    final exercise = vm.current?.exerciseDetail;
    if (exercise == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.hPad, vertical: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Route info chip
        if (vm.path != null)
          Align(alignment: Alignment.centerLeft, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('${vm.path!.routeCode} · Nivel ${vm.path!.currentDifficulty}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          )),
        const SizedBox(height: 20),

        // Si el ejercicio trae contenido jugable, el alumno lo hace acá y la
        // precisión se mide sola. Antes TODO ejercicio se calificaba a mano
        // ("¿respondió correctamente?"), aunque el contenido ya llegaba en la
        // respuesta del API sin que nada lo mostrara.
        if (_reproductor(exercise) case final player?) ...[
          Text(exercise.titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(exercise.instruccion,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.mutedText)),
          const SizedBox(height: 20),
          player,
          const SizedBox(height: 24),
        ] else ...[

        // Exercise card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(exercise.titulo,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
              if (exercise.usaTts)
                IconButton(
                  icon: Icon(Icons.volume_up_rounded, color: AppTheme.primary),
                  onPressed: () => TtsService.instance.speak(exercise.instruccion),
                  tooltip: 'Escuchar instrucción',
                ),
            ]),
            const SizedBox(height: 8),
            Text(exercise.instruccion, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.mutedText)),
            if (exercise.items.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              ...exercise.items.take(5).map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Icon(Icons.arrow_right_rounded, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_formatItem(item),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
                ]),
              )),
            ],
          ]),
        ),
        const SizedBox(height: 28),

        // Calificación manual: solo para los ejercicios que todavía no tienen
        // reproductor (voz, trazo). Ahí el adulto guía y marca el resultado.
        Text('¿El alumno respondió correctamente?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.close_rounded),
            label: const Text('Incorrecto'),
            onPressed: () => _rate(0.0),
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.riskRed, side: BorderSide(color: AppTheme.riskRed)),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            icon: const Icon(Icons.check_rounded),
            label: const Text('Correcto'),
            onPressed: () => _rate(1.0),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.activeGreen),
          )),
        ]),
        ],

        if (vm.current?.support != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.tertiary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3))),
            child: Row(children: [
              Icon(Icons.lightbulb_outline_rounded, color: AppTheme.tertiary, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(vm.current!.support!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.tertiary))),
            ]),
          ),
        ],
      ]),
    );
  }

  String _formatItem(Map<String, dynamic> item) {
    if (item.containsKey('palabra')) {
      final extra = item['silabas'] != null ? ' (${item['silabas']} síl.)' : '';
      return '${item['palabra']}$extra';
    }
    if (item.containsKey('oracion')) return item['oracion'] as String;
    if (item.containsKey('texto')) return item['texto'] as String;
    return item.values.map((v) => v.toString()).join(' · ');
  }

  Widget _centeredMessage(BuildContext context, {
    required IconData icon, required Color color,
    required String title, required String body, Widget? action,
  }) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)),
          child: Icon(icon, color: color, size: 48)),
        const SizedBox(height: 20),
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(body, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.mutedText), textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 24), action],
      ]),
    ));
  }
}
