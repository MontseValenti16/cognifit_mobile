import 'package:flutter/material.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Reproductor de los ejercicios del banco que se resuelven eligiendo una
/// opción. Cubre varios esquemas de ítem distintos porque el banco no es
/// homogéneo — cada ejercicio guarda sus datos como le conviene:
///
///  - `{estimulo, opciones, correcta}`   discriminación visual b/d, p/q
///  - `{palabra_base, opciones, correcta}` rimas
///  - `{palabra, distractor_1, distractor_2}` memoria de palabras
///  - `{par, son_iguales}`               ¿son iguales estas dos palabras?
///  - `{palabra, silabas}`               contar sílabas (elige el número)
///
/// [ChoiceQuestion.fromItem] normaliza todos esos casos a una sola forma, así
/// que agregar un esquema nuevo no obliga a tocar la interfaz.
class ChoiceQuestion {
  final String enunciado;
  final List<String> opciones;
  final String correcta;

  const ChoiceQuestion({
    required this.enunciado,
    required this.opciones,
    required this.correcta,
  });

  /// Devuelve null si el ítem no corresponde a un ejercicio de opciones
  /// (p. ej. los de voz o los de trazo), para que la pantalla no intente
  /// renderizar algo que no puede.
  static ChoiceQuestion? fromItem(Map<String, dynamic> item) {
    String s(Object? v) => (v ?? '').toString();

    // Opciones explícitas: el caso más directo.
    final opciones = (item['opciones'] as List?)?.map(s).toList();
    if (opciones != null && opciones.isNotEmpty && item['correcta'] != null) {
      return ChoiceQuestion(
        enunciado: s(item['estimulo'] ?? item['palabra_base'] ?? item['palabra']),
        opciones: opciones,
        correcta: s(item['correcta']),
      );
    }

    // Palabra + dos distractores: la correcta es la palabra.
    if (item['palabra'] != null && item['distractor_1'] != null) {
      final palabra = s(item['palabra']);
      return ChoiceQuestion(
        enunciado: '¿Cuál viste?',
        opciones: [palabra, s(item['distractor_1']), s(item['distractor_2'])]
          ..removeWhere((o) => o.isEmpty),
        correcta: palabra,
      );
    }

    // Par de palabras: ¿son iguales o distintas?
    if (item['par'] != null && item['son_iguales'] != null) {
      final par = (item['par'] as List?)?.map(s).toList() ?? const [];
      final iguales = item['son_iguales'] == true;
      return ChoiceQuestion(
        enunciado: par.join('     '),
        opciones: const ['Iguales', 'Distintas'],
        correcta: iguales ? 'Iguales' : 'Distintas',
      );
    }

    // Conteo de sílabas: las opciones son números alrededor del correcto.
    if (item['palabra'] != null && item['silabas'] is num) {
      final n = (item['silabas'] as num).toInt();
      final opciones = {1, 2, 3, 4, n}.toList()..sort();
      return ChoiceQuestion(
        enunciado: s(item['palabra']),
        opciones: opciones.map((o) => o.toString()).toList(),
        correcta: n.toString(),
      );
    }

    return null;
  }
}

class ChoicePlayer extends StatefulWidget {
  final List<ChoiceQuestion> preguntas;
  final bool usaTts;

  /// Precisión 0..1 sobre el total de preguntas.
  final void Function(double accuracy, int aciertos, int total) onFinish;

  const ChoicePlayer({
    super.key,
    required this.preguntas,
    required this.onFinish,
    this.usaTts = false,
  });

  @override
  State<ChoicePlayer> createState() => _ChoicePlayerState();
}

class _ChoicePlayerState extends State<ChoicePlayer> {
  int _indice = 0;
  int _aciertos = 0;
  String? _elegida;

  ChoiceQuestion get _q => widget.preguntas[_indice];

  void _elegir(String opcion) {
    if (_elegida != null) return; // ya respondió: evita doble conteo
    final acerto = opcion == _q.correcta;
    if (acerto) _aciertos++;
    setState(() => _elegida = opcion);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_indice >= widget.preguntas.length - 1) {
        widget.onFinish(
          _aciertos / widget.preguntas.length,
          _aciertos,
          widget.preguntas.length,
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
    final respondida = _elegida != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('${_indice + 1} de ${widget.preguntas.length}',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: const Color(0xFF9E9CAD))),
      const SizedBox(height: 16),

      Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
        ),
        child: Column(children: [
          Text(_q.enunciado,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'serif',
                  )),
          if (widget.usaTts && _q.enunciado.isNotEmpty)
            IconButton(
              icon: Icon(Icons.volume_up_rounded, color: AppTheme.primary),
              tooltip: 'Escuchar',
              onPressed: () => TtsService.instance.speak(_q.enunciado),
            ),
        ]),
      ),

      const SizedBox(height: 24),

      Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final opcion in _q.opciones)
            _OpcionBoton(
              texto: opcion,
              estado: !respondida
                  ? _EstadoOpcion.neutral
                  : opcion == _q.correcta
                      ? _EstadoOpcion.correcta
                      : (opcion == _elegida ? _EstadoOpcion.incorrecta : _EstadoOpcion.neutral),
              onTap: () => _elegir(opcion),
            ),
        ],
      ),
    ]);
  }
}

enum _EstadoOpcion { neutral, correcta, incorrecta }

class _OpcionBoton extends StatelessWidget {
  final String texto;
  final _EstadoOpcion estado;
  final VoidCallback onTap;
  const _OpcionBoton({required this.texto, required this.estado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (color, borde) = switch (estado) {
      _EstadoOpcion.correcta => (AppTheme.activeGreen, AppTheme.activeGreen),
      _EstadoOpcion.incorrecta => (AppTheme.riskRed, AppTheme.riskRed),
      _EstadoOpcion.neutral => (null, AppTheme.outline),
    };

    return Semantics(
      button: true,
      label: 'Opción $texto',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minWidth: 92, minHeight: 92),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color?.withValues(alpha: 0.12) ?? Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borde.withValues(alpha: estado == _EstadoOpcion.neutral ? 0.5 : 1),
              width: estado == _EstadoOpcion.neutral ? 1.2 : 2.5,
            ),
          ),
          child: Text(texto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'serif',
                    color: color,
                  )),
        ),
      ),
    );
  }
}
