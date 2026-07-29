import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';

class ReadingPlayer extends StatefulWidget {
  final String texto;
  final String instruccion;
  final bool usaTts;

  final int? metaPalabrasPorMinuto;

  final int? repeticiones;

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
    _tick = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted && _reloj.isRunning) setState(() {});
    });
  }

  void _terminarVuelta() {
    _tick?.cancel();
    _reloj.stop();
    final segundos = _reloj.elapsedMilliseconds / 1000;
    final ppm = segundos < 1 ? 0 : (_totalPalabras * 60 / segundos).round();

    setState(() => _ppmUltimaVuelta = ppm);

    if (_vueltaActual < _vueltasPedidas) {
      setState(() => _vueltaActual++);
      return;
    }

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
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.usaTts)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.volume_up_rounded, color: AppTheme.primary),
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
                  ?.copyWith(color: AppTheme.mutedText)),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                  ?.copyWith(color: AppTheme.mutedText)),
        ],
      ]),
    );
  }
}
