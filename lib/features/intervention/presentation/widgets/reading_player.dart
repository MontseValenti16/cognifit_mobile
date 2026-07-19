import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Reproductor de los ejercicios de lectura del banco de intervención.
///
/// 13 de los 29 ejercicios (lectura guiada, repetida, temporizada, karaoke y
/// denominación rápida) no traen `items`: traen un texto corrido. Hasta ahora
/// la pantalla solo mostraba título e instrucción, así que el ejercicio se
/// hacía fuera de la app y un adulto marcaba a mano si había salido bien.
///
/// Acá el alumno lee y la app mide: cuenta las palabras del texto y el tiempo
/// real de lectura para calcular palabras por minuto, que es la medida clínica
/// estándar de fluidez y justamente el perfil que estos ejercicios atienden.
class ReadingPlayer extends StatefulWidget {
  final String texto;
  final String instruccion;
  final bool usaTts;

  /// Meta de palabras/minuto del banco. Si viene, se usa para calcular la
  /// precisión reportada a la ruta adaptativa.
  final int? metaPalabrasPorMinuto;

  /// Repeticiones que pide el ejercicio (lectura repetida).
  final int? repeticiones;

  /// Devuelve la precisión 0..1 que se reporta a /next-exercise.
  final void Function(double accuracy, int palabrasPorMinuto) onFinish;

  const ReadingPlayer({
    super.key,
    required this.texto,
    required this.instruccion,
    required this.onFinish,
    this.usaTts = false,
    this.metaPalabrasPorMinuto,
    this.repeticiones,
  });

  @override
  State<ReadingPlayer> createState() => _ReadingPlayerState();
}

class _ReadingPlayerState extends State<ReadingPlayer> {
  final Stopwatch _reloj = Stopwatch();
  Timer? _tick;
  int _vueltaActual = 1;
  int? _ppmUltimaVuelta;

  int get _totalPalabras =>
      widget.texto.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length;

  int get _vueltasPedidas => widget.repeticiones ?? 1;

  bool get _leyendo => _reloj.isRunning;

  @override
  void dispose() {
    _tick?.cancel();
    _reloj.stop();
    TtsService.instance.stop();
    super.dispose();
  }

  void _empezar() {
    setState(() {
      _reloj
        ..reset()
        ..start();
    });
    // Refresca el cronómetro en pantalla sin recalcular nada más.
    _tick = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted && _reloj.isRunning) setState(() {});
    });
  }

  void _terminarVuelta() {
    _tick?.cancel();
    _reloj.stop();
    final segundos = _reloj.elapsedMilliseconds / 1000;
    // Guarda contra divisiones absurdas si alguien toca "terminé" de inmediato.
    final ppm = segundos < 1 ? 0 : (_totalPalabras * 60 / segundos).round();

    setState(() => _ppmUltimaVuelta = ppm);

    if (_vueltaActual < _vueltasPedidas) {
      setState(() => _vueltaActual++);
      return;
    }

    // Precisión relativa a la meta del banco, tope 1.0. Sin meta declarada no
    // hay contra qué comparar, así que se reporta el punto medio en vez de
    // inventar un desempeño que no se midió.
    final meta = widget.metaPalabrasPorMinuto;
    final accuracy = meta == null || meta <= 0
        ? 0.5
        : (ppm / meta).clamp(0.0, 1.0).toDouble();
    widget.onFinish(accuracy, ppm);
  }

  @override
  Widget build(BuildContext context) {
    final segundos = _reloj.elapsedMilliseconds ~/ 1000;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (_vueltasPedidas > 1)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Lectura $_vueltaActual de $_vueltasPedidas',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary, fontWeight: FontWeight.w700)),
        ),

      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.usaTts)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary),
                tooltip: 'Escuchar el texto',
                onPressed: () => TtsService.instance.speak(widget.texto),
              ),
            ),
          Text(
            widget.texto,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.8,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 14),
          Text('$_totalPalabras palabras',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: const Color(0xFF9E9CAD))),
        ]),
      ),

      const SizedBox(height: 20),

      if (_leyendo) ...[
        Text('$segundos s',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.primary)),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_rounded),
          label: const Text('Terminé de leer'),
          onPressed: _terminarVuelta,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.activeGreen),
        ),
      ] else ...[
        if (_ppmUltimaVuelta != null) ...[
          _ResultadoLectura(
            ppm: _ppmUltimaVuelta!,
            meta: widget.metaPalabrasPorMinuto,
          ),
          const SizedBox(height: 14),
        ],
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(_ppmUltimaVuelta == null ? 'Empezar a leer' : 'Leer otra vez'),
          onPressed: _empezar,
        ),
      ],
    ]);
  }
}

class _ResultadoLectura extends StatelessWidget {
  final int ppm;
  final int? meta;
  const _ResultadoLectura({required this.ppm, this.meta});

  @override
  Widget build(BuildContext context) {
    final alcanzo = meta != null && ppm >= meta!;
    final color = alcanzo ? AppTheme.activeGreen : AppTheme.pendingOrange;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text('$ppm palabras por minuto',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, color: color)),
        if (meta != null) ...[
          const SizedBox(height: 4),
          Text(alcanzo ? '¡Alcanzaste la meta de $meta!' : 'La meta es $meta',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: const Color(0xFF6B6880))),
        ],
      ]),
    );
  }
}
