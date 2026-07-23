import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'choice_player.dart';

/// Reproductor de los ejercicios de comprensión (vía universal por grado).
///
/// Un ejercicio de comprensión es un texto seguido de preguntas, así que no
/// encaja ni en [ReadingPlayer] (que solo mide fluidez) ni en [ChoicePlayer]
/// (que no tiene dónde poner el texto).
///
/// Decisión clínica importante: **el texto sigue disponible mientras se
/// responde**. Ocultarlo mediría memoria, no comprensión — y en un alumno con
/// dificultades lectoras esas dos cosas se confunden con facilidad. Volver al
/// texto a verificar es exactamente la estrategia que el ejercicio quiere
/// enseñar, no una trampa.
class ComprehensionPlayer extends StatefulWidget {
  final String texto;
  final List<ChoiceQuestion> preguntas;
  final bool usaTts;

  /// Pide al alumno predecir su desempeño antes de responder y se lo compara
  /// al final. Es el ejercicio de metacognición del banco.
  final bool autoevaluacion;

  /// Si viene, se cronometra la lectura y se reportan palabras por minuto.
  final int? metaPalabrasPorMinuto;

  /// [accuracy] es la precisión en las preguntas, 0..1. [ppm] es null cuando
  /// el ejercicio no cronometra.
  final void Function(double accuracy, int aciertos, int total, int? ppm) onFinish;

  const ComprehensionPlayer({
    super.key,
    required this.texto,
    required this.preguntas,
    required this.onFinish,
    this.usaTts = false,
    this.autoevaluacion = false,
    this.metaPalabrasPorMinuto,
  });

  @override
  State<ComprehensionPlayer> createState() => _ComprehensionPlayerState();
}

enum _Fase { leyendo, prediciendo, respondiendo, resultado }

class _ComprehensionPlayerState extends State<ComprehensionPlayer> {
  _Fase _fase = _Fase.leyendo;

  final Stopwatch _relojLectura = Stopwatch();
  Timer? _tick;
  int? _ppm;

  int? _prediccion;
  int _indice = 0;
  int _aciertos = 0;
  String? _elegida;

  /// El texto se puede plegar mientras se responde para dejar sitio a las
  /// opciones, pero nunca desaparece.
  bool _textoExpandido = true;

  bool get _cronometra => widget.metaPalabrasPorMinuto != null;

  int get _totalPalabras =>
      widget.texto.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length;

  ChoiceQuestion get _q => widget.preguntas[_indice];

  @override
  void initState() {
    super.initState();
    if (_cronometra) {
      _relojLectura.start();
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _relojLectura.isRunning) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _relojLectura.stop();
    TtsService.instance.stop();
    super.dispose();
  }

  void _terminarLectura() {
    if (_cronometra) {
      _tick?.cancel();
      _relojLectura.stop();
      final seg = _relojLectura.elapsedMilliseconds / 1000;
      _ppm = seg < 1 ? 0 : (_totalPalabras * 60 / seg).round();
    }
    setState(() {
      _textoExpandido = false;
      _fase = widget.autoevaluacion ? _Fase.prediciendo : _Fase.respondiendo;
    });
  }

  void _elegir(String opcion) {
    if (_elegida != null) return;
    if (opcion == _q.correcta) _aciertos++;
    setState(() => _elegida = opcion);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_indice >= widget.preguntas.length - 1) {
        setState(() => _fase = _Fase.resultado);
        // La precisión que viaja a la ruta adaptativa es la de comprensión,
        // no las palabras por minuto: leer rápido sin entender no es un buen
        // desempeño, y reportar ppm como precisión premiaría justamente eso.
        widget.onFinish(
          _aciertos / widget.preguntas.length,
          _aciertos,
          widget.preguntas.length,
          _ppm,
        );
      } else {
        setState(() {
          _indice++;
          _elegida = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _TextoPlegable(
        texto: widget.texto,
        expandido: _textoExpandido,
        totalPalabras: _totalPalabras,
        usaTts: widget.usaTts,
        // Durante la lectura no tiene sentido plegarlo.
        onToggle: _fase == _Fase.leyendo
            ? null
            : () => setState(() => _textoExpandido = !_textoExpandido),
      ),
      const SizedBox(height: 20),
      switch (_fase) {
        _Fase.leyendo => _BloqueLectura(
            segundos: _cronometra ? _relojLectura.elapsedMilliseconds ~/ 1000 : null,
            onListo: _terminarLectura,
          ),
        _Fase.prediciendo => _BloquePrediccion(
            total: widget.preguntas.length,
            onElegir: (n) => setState(() {
              _prediccion = n;
              _fase = _Fase.respondiendo;
            }),
          ),
        _Fase.respondiendo => _BloquePreguntas(
            pregunta: _q,
            indice: _indice,
            total: widget.preguntas.length,
            elegida: _elegida,
            usaTts: widget.usaTts,
            onElegir: _elegir,
          ),
        _Fase.resultado => _BloqueResultado(
            aciertos: _aciertos,
            total: widget.preguntas.length,
            prediccion: _prediccion,
            ppm: _ppm,
            meta: widget.metaPalabrasPorMinuto,
          ),
      },
    ]);
  }
}

// ─── Texto ───────────────────────────────────────────────────────────────────

class _TextoPlegable extends StatelessWidget {
  final String texto;
  final bool expandido;
  final int totalPalabras;
  final bool usaTts;
  final VoidCallback? onToggle;

  const _TextoPlegable({
    required this.texto,
    required this.expandido,
    required this.totalPalabras,
    required this.usaTts,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (onToggle != null)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(children: [
                Icon(Icons.article_outlined, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(expandido ? 'El texto' : 'Ver el texto otra vez',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ),
                Icon(expandido ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppTheme.primary),
              ]),
            ),
          ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState:
              expandido ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: EdgeInsets.fromLTRB(20, onToggle == null ? 20 : 0, 20, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (usaTts)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.volume_up_rounded, color: AppTheme.primary),
                    tooltip: 'Escuchar el texto',
                    onPressed: () => TtsService.instance.speak(texto),
                  ),
                ),
              Text(texto,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.75,
                        fontFamily: 'serif',
                      )),
              const SizedBox(height: 12),
              Text('$totalPalabras palabras',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppTheme.mutedText)),
            ]),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}

// ─── Fases ───────────────────────────────────────────────────────────────────

class _BloqueLectura extends StatelessWidget {
  final int? segundos;
  final VoidCallback onListo;
  const _BloqueLectura({required this.segundos, required this.onListo});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (segundos != null) ...[
        Text('$segundos s',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.primary)),
        const SizedBox(height: 12),
      ],
      ElevatedButton.icon(
        icon: const Icon(Icons.check_rounded),
        label: const Text('Ya leí, quiero responder'),
        onPressed: onListo,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.activeGreen),
      ),
    ]);
  }
}

class _BloquePrediccion extends StatelessWidget {
  final int total;
  final void Function(int) onElegir;
  const _BloquePrediccion({required this.total, required this.onElegir});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Antes de empezar: de $total preguntas, ¿cuántas crees que vas a acertar?',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text('No se califica esta respuesta. Es para que compares al final.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppTheme.mutedText)),
      const SizedBox(height: 18),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        children: [
          for (var n = 0; n <= total; n++)
            OutlinedButton(
              onPressed: () => onElegir(n),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(58, 58),
                shape: const CircleBorder(),
              ),
              child: Text('$n',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    ]);
  }
}

class _BloquePreguntas extends StatelessWidget {
  final ChoiceQuestion pregunta;
  final int indice;
  final int total;
  final String? elegida;
  final bool usaTts;
  final void Function(String) onElegir;

  const _BloquePreguntas({
    required this.pregunta,
    required this.indice,
    required this.total,
    required this.elegida,
    required this.usaTts,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    final respondida = elegida != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Pregunta ${indice + 1} de $total',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: AppTheme.mutedText)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
          child: Text(pregunta.enunciado,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.4)),
        ),
        if (usaTts)
          IconButton(
            icon: Icon(Icons.volume_up_rounded, color: AppTheme.primary),
            tooltip: 'Escuchar la pregunta',
            onPressed: () => TtsService.instance.speak(pregunta.enunciado),
          ),
      ]),
      const SizedBox(height: 18),
      for (final opcion in pregunta.opciones)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _OpcionLarga(
            texto: opcion,
            estado: !respondida
                ? _Estado.neutral
                : opcion == pregunta.correcta
                    ? _Estado.correcta
                    : (opcion == elegida ? _Estado.incorrecta : _Estado.neutral),
            onTap: () => onElegir(opcion),
          ),
        ),
    ]);
  }
}

class _BloqueResultado extends StatelessWidget {
  final int aciertos;
  final int total;
  final int? prediccion;
  final int? ppm;
  final int? meta;

  const _BloqueResultado({
    required this.aciertos,
    required this.total,
    this.prediccion,
    this.ppm,
    this.meta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: [
        Text('$aciertos de $total',
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.primary)),
        Text('respuestas correctas',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.mutedText)),
        if (prediccion != null) ...[
          const Divider(height: 28),
          Text(_mensajePrediccion(prediccion!, aciertos),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Habías dicho $prediccion',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.mutedText)),
        ],
        if (ppm != null) ...[
          const Divider(height: 28),
          Text('Leíste a $ppm palabras por minuto',
              style: Theme.of(context).textTheme.titleSmall),
          if (meta != null)
            Text('La referencia para tu grado es $meta',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.mutedText)),
        ],
      ]),
    );
  }

  /// El mensaje habla de la calibración, no del acierto: el punto del ejercicio
  /// es notar si uno se conoce, y quedarse corto también es información útil.
  static String _mensajePrediccion(int predicho, int real) {
    final dif = real - predicho;
    if (dif == 0) return 'Calculaste exacto cómo te iba a ir.';
    if (dif > 0) return 'Te fue mejor de lo que esperabas.';
    return 'Esperabas más de las que salieron. Vale la pena releer con calma.';
  }
}

// ─── Opción ──────────────────────────────────────────────────────────────────

enum _Estado { neutral, correcta, incorrecta }

/// Las opciones de comprensión son frases, no letras sueltas, así que se
/// presentan en filas anchas y no en los cuadros de [ChoicePlayer].
class _OpcionLarga extends StatelessWidget {
  final String texto;
  final _Estado estado;
  final VoidCallback onTap;
  const _OpcionLarga({required this.texto, required this.estado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (color, borde) = switch (estado) {
      _Estado.correcta => (AppTheme.activeGreen, AppTheme.activeGreen),
      _Estado.incorrecta => (AppTheme.riskRed, AppTheme.riskRed),
      _Estado.neutral => (null, AppTheme.outline),
    };

    return Semantics(
      button: true,
      label: 'Opción $texto',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: color?.withValues(alpha: 0.1) ?? AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borde.withValues(alpha: estado == _Estado.neutral ? 0.5 : 1),
              width: estado == _Estado.neutral ? 1.2 : 2.2,
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Text(texto,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.35,
                        color: color,
                        fontWeight:
                            estado == _Estado.neutral ? FontWeight.w500 : FontWeight.w700,
                      )),
            ),
            if (estado == _Estado.correcta)
              Icon(Icons.check_circle_rounded, color: AppTheme.activeGreen),
            if (estado == _Estado.incorrecta)
              Icon(Icons.cancel_rounded, color: AppTheme.riskRed),
          ]),
        ),
      ),
    );
  }
}
