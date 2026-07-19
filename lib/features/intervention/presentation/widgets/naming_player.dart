import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Cómo se dibuja cada casilla de la rejilla.
enum NamingKind { letras, colores, objetos }

/// Reproductor de los ejercicios de denominación rápida (RAN).
///
/// El alumno nombra en voz alta las 40 casillas lo más rápido que puede y la
/// app mide el **tiempo total**. Esa es la medida clínica de la prueba: la
/// denominación rápida evalúa cuán automatizado está el acceso al nombre, no
/// si el alumno conoce las letras — a esta edad las conoce, lo que cuesta es
/// recuperarlas rápido.
///
/// Por eso no hace falta reconocimiento de voz para la medida principal, que
/// era lo que tenía a estos tres ejercicios sin jugarse: alcanza con la
/// rejilla y el cronómetro.
class NamingPlayer extends StatefulWidget {
  final List<String> grid;
  final int columnas;
  final NamingKind kind;

  /// Solo para [NamingKind.colores]: nombre → color.
  final Map<String, Color> paleta;

  /// Solo para [NamingKind.objetos]: nombre → emoji.
  final Map<String, String> iconos;

  /// Devuelve la precisión reportada a la ruta y el tiempo real en segundos.
  final void Function(double accuracy, int segundos) onFinish;

  /// Inyectable solo para pruebas: `pump()` mueve el reloj falso del test, no
  /// el del sistema, así que con un Stopwatch real no se puede verificar que
  /// la medición sea correcta.
  final Stopwatch Function()? crearReloj;

  const NamingPlayer({
    super.key,
    required this.grid,
    required this.kind,
    required this.onFinish,
    this.columnas = 5,
    this.paleta = const {},
    this.iconos = const {},
    this.crearReloj,
  });

  @override
  State<NamingPlayer> createState() => _NamingPlayerState();
}

class _NamingPlayerState extends State<NamingPlayer> {
  late final Stopwatch _reloj = (widget.crearReloj ?? Stopwatch.new)();
  Timer? _tick;
  int? _segundosFinales;

  bool get _corriendo => _reloj.isRunning;

  @override
  void dispose() {
    _tick?.cancel();
    _reloj.stop();
    super.dispose();
  }

  void _empezar() {
    setState(() => _reloj
      ..reset()
      ..start());
    _tick = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted && _reloj.isRunning) setState(() {});
    });
  }

  void _terminar() {
    _tick?.cancel();
    _reloj.stop();
    final seg = (_reloj.elapsedMilliseconds / 1000).round();
    setState(() => _segundosFinales = seg);

    // No hay norma de referencia en el repo para tiempos de denominación
    // rápida en español mexicano, y estos tiempos solo significan algo contra
    // una norma. Se reporta el punto medio —igual que la lectura sin meta
    // declarada— en vez de inventar un umbral que decidiría si un alumno
    // sube de nivel. El tiempo real sí se entrega, para cuando haya norma.
    widget.onFinish(0.5, seg);
  }

  @override
  Widget build(BuildContext context) {
    final seg = _reloj.elapsedMilliseconds ~/ 1000;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.grid.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.columnas,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (_, i) => _Casilla(
            valor: widget.grid[i],
            kind: widget.kind,
            color: widget.paleta[widget.grid[i]],
            icono: widget.iconos[widget.grid[i]],
          ),
        ),
      ),
      const SizedBox(height: 18),

      if (_corriendo) ...[
        Text('$seg s',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.primary)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_rounded),
          label: const Text('Terminé'),
          onPressed: _terminar,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.activeGreen),
        ),
      ] else if (_segundosFinales != null) ...[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Text('${_segundosFinales!} segundos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: AppTheme.primary)),
            const SizedBox(height: 4),
            Text('${widget.grid.length} casillas',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: const Color(0xFF9E9CAD))),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Intentar de nuevo'),
          onPressed: _empezar,
        ),
      ] else
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Empezar'),
          onPressed: _empezar,
        ),
    ]);
  }
}

class _Casilla extends StatelessWidget {
  final String valor;
  final NamingKind kind;
  final Color? color;
  final String? icono;

  const _Casilla({
    required this.valor,
    required this.kind,
    this.color,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: valor,
      child: Center(child: switch (kind) {
        NamingKind.colores => Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color ?? Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        NamingKind.objetos => Text(icono ?? '?',
            style: const TextStyle(fontSize: 28)),
        NamingKind.letras => Text(valor,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w600,
                )),
      }),
    );
  }
}
