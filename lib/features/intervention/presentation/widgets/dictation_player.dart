import 'package:flutter/material.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Reproductor de los ejercicios de dictado (`modalidad: teclado_tts`).
///
/// El ítem trae solo `{target}`: la app dicta la palabra o la frase y el
/// alumno la escribe. La comparación ignora mayúsculas y espacios de sobra
/// pero **no** ignora acentos ni ortografía: el dictado existe justamente
/// para evaluar eso.
class DictationPlayer extends StatefulWidget {
  final List<String> targets;
  final void Function(double accuracy, int aciertos, int total) onFinish;

  const DictationPlayer({super.key, required this.targets, required this.onFinish});

  @override
  State<DictationPlayer> createState() => _DictationPlayerState();
}

class _DictationPlayerState extends State<DictationPlayer> {
  final _controller = TextEditingController();
  int _indice = 0;
  int _aciertos = 0;
  bool? _ultimoCorrecto;

  String get _target => widget.targets[_indice];

  @override
  void initState() {
    super.initState();
    // Se dicta apenas aparece: el alumno no tiene que buscar el botón.
    WidgetsBinding.instance.addPostFrameCallback((_) => _dictar());
  }

  @override
  void dispose() {
    _controller.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _dictar() => TtsService.instance.speak(_target);

  void _comprobar() {
    if (_ultimoCorrecto != null) return;
    final escrito = _controller.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final esperado = _target.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final acerto = escrito == esperado;
    if (acerto) _aciertos++;
    setState(() => _ultimoCorrecto = acerto);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_indice >= widget.targets.length - 1) {
        widget.onFinish(_aciertos / widget.targets.length, _aciertos, widget.targets.length);
        return;
      }
      setState(() {
        _indice++;
        _ultimoCorrecto = null;
        _controller.clear();
      });
      _dictar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final respondido = _ultimoCorrecto != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('${_indice + 1} de ${widget.targets.length}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF9E9CAD))),
      const SizedBox(height: 20),

      Center(
        child: IconButton.filled(
          iconSize: 42,
          padding: const EdgeInsets.all(20),
          icon: const Icon(Icons.volume_up_rounded),
          tooltip: 'Escuchar de nuevo',
          onPressed: _dictar,
        ),
      ),
      const SizedBox(height: 8),
      Text('Toca para escuchar otra vez',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9E9CAD))),

      const SizedBox(height: 24),
      TextField(
        controller: _controller,
        enabled: !respondido,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'serif'),
        decoration: InputDecoration(
          hintText: 'Escribe lo que escuchaste',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onSubmitted: (_) => _comprobar(),
      ),

      if (respondido) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (_ultimoCorrecto! ? AppTheme.activeGreen : AppTheme.riskRed).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Icon(_ultimoCorrecto! ? Icons.check_circle_rounded : Icons.info_rounded,
                color: _ultimoCorrecto! ? AppTheme.activeGreen : AppTheme.riskRed),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _ultimoCorrecto! ? '¡Muy bien!' : 'Se escribe: $_target',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _ultimoCorrecto! ? AppTheme.activeGreen : AppTheme.riskRed),
              ),
            ),
          ]),
        ),
      ] else ...[
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _comprobar, child: const Text('Comprobar')),
      ],
    ]);
  }
}
