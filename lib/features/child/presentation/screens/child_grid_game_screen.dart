import 'package:flutter/material.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/child_grid_games.dart';
import '../widgets/child_game_widgets.dart';

/// Juego de búsqueda visual sobre una cuadrícula de 5x4.
///
/// El alumno marca **todas** las casillas que cumplen la consigna, en vez de
/// elegir una entre cuatro. Se corrige al terminar y no casilla por casilla:
/// avisar en cada toque convertiría el ejercicio en ensayo y error, y lo que
/// se quiere observar es si reconoce la letra sin ayuda mientras sostiene la
/// búsqueda.
class ChildGridGameScreen extends StatefulWidget {
  final String studentName;

  /// Permite inyectar otra lista en las pruebas.
  final List<GridGame> juegos;

  ChildGridGameScreen({
    super.key,
    required this.studentName,
    List<GridGame>? juegos,
  }) : juegos = juegos ?? kGridGames;

  @override
  State<ChildGridGameScreen> createState() => _ChildGridGameScreenState();
}

class _ChildGridGameScreenState extends State<ChildGridGameScreen> {
  int _indice = 0;
  final Set<int> _tocadas = {};
  bool _revisado = false;

  GridGame get _juego => widget.juegos[_indice];

  /// Marcadas correctamente.
  Set<int> get _aciertos => _tocadas.intersection(_juego.objetivos);

  /// Marcadas que no correspondían.
  Set<int> get _errores => _tocadas.difference(_juego.objetivos);

  /// Objetivos que se dejaron pasar. Se muestran al corregir porque omitir es
  /// un error distinto de marcar de más, y conviene que el niño lo vea.
  Set<int> get _omitidas => _juego.objetivos.difference(_tocadas);

  bool get _perfecto => _errores.isEmpty && _omitidas.isEmpty;

  void _tocar(int i) {
    if (_revisado) return;
    setState(() => _tocadas.contains(i) ? _tocadas.remove(i) : _tocadas.add(i));
  }

  void _revisar() => setState(() => _revisado = true);

  void _siguiente() {
    if (_indice >= widget.juegos.length - 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _indice++;
      _tocadas.clear();
      _revisado = false;
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(children: [
          ChildProgressBar(
            current: _indice + (_revisado ? 1 : 0),
            total: widget.juegos.length,
            onClose: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_juego.sectionLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8)),
                ),
                const SizedBox(height: 14),
                Text(_juego.question,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: AppTheme.onSurface)),
                const SizedBox(height: 6),
                Text(_juego.instruction,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: const Color(0xFF6B6880), fontSize: 14)),
                const SizedBox(height: 10),

                // Cuántas lleva marcadas. Sin decir si están bien: eso es la
                // corrección, y darlo antes volvería el juego ensayo y error.
                if (!_revisado)
                  Text('Marcadas: ${_tocadas.length}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primary, fontWeight: FontWeight.w700)),

                const SizedBox(height: 14),
                _Cuadricula(
                  juego: _juego,
                  tocadas: _tocadas,
                  revisado: _revisado,
                  omitidas: _omitidas,
                  onTap: _tocar,
                ),
                const SizedBox(height: 20),

                if (_revisado) ...[
                  ChildFeedbackBanner(
                    isCorrect: _perfecto,
                    studentName: widget.studentName,
                    explanation: _mensaje(),
                  ),
                  const SizedBox(height: 12),
                ] else
                  Center(
                    child: _BotonAuxiliar(
                      icon: Icons.volume_up_rounded,
                      label: 'Escuchar',
                      onTap: () => TtsService.instance.speak(_juego.instruction),
                    ),
                  ),
                const SizedBox(height: 90),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _revisado
                    ? _siguiente
                    : (_tocadas.isEmpty ? null : _revisar),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _revisado && _perfecto ? AppTheme.activeGreen : AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _revisado
                      ? (_indice >= widget.juegos.length - 1 ? 'Terminar' : 'Siguiente')
                      : 'Revisar',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /// El mensaje distingue marcar de más de dejar pasar: son errores distintos
  /// y se corrigen de manera distinta.
  String _mensaje() {
    if (_perfecto) return _juego.explanation;
    final partes = <String>[];
    if (_omitidas.isNotEmpty) {
      partes.add(_omitidas.length == 1
          ? 'Se te pasó 1'
          : 'Se te pasaron ${_omitidas.length}');
    }
    if (_errores.isNotEmpty) {
      partes.add(_errores.length == 1
          ? 'marcaste 1 de más'
          : 'marcaste ${_errores.length} de más');
    }
    return '${partes.join(' y ')}. ${_juego.explanation}';
  }
}

class _Cuadricula extends StatelessWidget {
  final GridGame juego;
  final Set<int> tocadas;
  final bool revisado;
  final Set<int> omitidas;
  final void Function(int) onTap;

  const _Cuadricula({
    required this.juego,
    required this.tocadas,
    required this.revisado,
    required this.omitidas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // El texto se achica cuando la casilla lleva una palabra en vez de una
    // sola letra, para que no se corte.
    final maxLargo =
        juego.celdas.map((c) => c.length).reduce((a, b) => a > b ? a : b);
    final fuente = maxLargo <= 1 ? 34.0 : (maxLargo <= 3 ? 22.0 : 16.0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: juego.celdas.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: juego.columnas,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        final marcada = tocadas.contains(i);
        final esObjetivo = juego.objetivos.contains(i);

        Color borde = AppTheme.outline.withValues(alpha: 0.5);
        Color fondo = Colors.white;
        double grosor = 1.6;

        if (!revisado && marcada) {
          borde = AppTheme.primary;
          fondo = AppTheme.primary.withValues(alpha: 0.10);
          grosor = 2.6;
        } else if (revisado) {
          if (marcada && esObjetivo) {
            borde = AppTheme.activeGreen;
            fondo = AppTheme.activeGreen.withValues(alpha: 0.12);
            grosor = 2.6;
          } else if (marcada && !esObjetivo) {
            borde = AppTheme.riskRed;
            fondo = AppTheme.riskRed.withValues(alpha: 0.10);
            grosor = 2.6;
          } else if (omitidas.contains(i)) {
            // Se señala en naranja lo que se dejó pasar: no es lo mismo
            // equivocarse que no verlo.
            borde = AppTheme.pendingOrange;
            fondo = AppTheme.pendingOrange.withValues(alpha: 0.10);
            grosor = 2.6;
          }
        }

        return Semantics(
          button: !revisado,
          selected: marcada,
          label: juego.celdas[i],
          child: GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borde, width: grosor),
              ),
              child: Stack(alignment: Alignment.center, children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: FittedBox(
                      child: Text(juego.celdas[i],
                          style: TextStyle(
                            fontSize: fuente,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'serif',
                            color: AppTheme.onSurface,
                          )),
                    ),
                  ),
                ),
                if (revisado && marcada && esObjetivo)
                  const Positioned(
                      top: 3,
                      right: 3,
                      child: Icon(Icons.check_rounded,
                          size: 15, color: AppTheme.activeGreen)),
                if (revisado && marcada && !esObjetivo)
                  const Positioned(
                      top: 3,
                      right: 3,
                      child: Icon(Icons.close_rounded,
                          size: 15, color: AppTheme.riskRed)),
                if (revisado && omitidas.contains(i))
                  const Positioned(
                      top: 3,
                      right: 3,
                      child: Icon(Icons.remove_red_eye_outlined,
                          size: 14, color: AppTheme.pendingOrange)),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _BotonAuxiliar extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BotonAuxiliar({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: AppTheme.tertiary),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.tertiary)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppTheme.tertiary.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
    );
  }
}
