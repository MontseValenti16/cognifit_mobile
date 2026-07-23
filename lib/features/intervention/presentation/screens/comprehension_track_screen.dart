import 'package:flutter/material.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../domain/entities/intervention_entity.dart';
import '../../domain/repositories/intervention_repository.dart';
import '../widgets/choice_player.dart';
import '../widgets/comprehension_player.dart';

/// Catálogo de comprensión del grado del alumno.
///
/// Es la puerta de la **vía universal**: a diferencia de [InterventionScreen],
/// no parte de un diagnóstico. El tamizaje mide a nivel palabra y no detecta
/// dificultades de comprensión, así que estos ejercicios se ofrecen a cualquier
/// alumno del grado, tenga o no perfil de riesgo.
///
/// El grado no se envía: lo resuelve el servidor a partir del alumno.
class ComprehensionTrackScreen extends StatefulWidget {
  final InterventionRepository repository;
  final String studentId;
  final String studentName;

  const ComprehensionTrackScreen({
    super.key,
    required this.repository,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ComprehensionTrackScreen> createState() => _ComprehensionTrackScreenState();
}

class _ComprehensionTrackScreenState extends State<ComprehensionTrackScreen> {
  late Future<ComprehensionTrackEntity> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = widget.repository.getComprehensionTrack(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Comprensión lectora'),
        actions: const [ThemeToggleButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(widget.studentName,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.mutedText)),
          ),
        ),
      ),
      body: FutureBuilder<ComprehensionTrackEntity>(
        future: _futuro,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            // Se distingue el motivo en vez de culpar siempre a la conexión.
            // Decir "revisa tu internet" cuando el servicio está caído manda
            // al docente a buscar el problema donde no está.
            final e = snap.error;
            final esServicioCaido =
                e is ApiException && (e.statusCode == 503 || e.statusCode == 502);
            final sinGrado = e is ApiException && e.statusCode == 409;

            return _Aviso(
              icono: sinGrado
                  ? Icons.school_outlined
                  : (esServicioCaido ? Icons.dns_outlined : Icons.wifi_off_rounded),
              titulo: sinGrado
                  ? 'Al alumno le falta el grado'
                  : (esServicioCaido
                      ? 'El servicio no está disponible'
                      : 'Sin conexión'),
              detalle: sinGrado
                  ? 'La comprensión se entrega por grado escolar. Asigna el alumno a un grupo para continuar.'
                  : (esServicioCaido
                      ? 'El material existe, pero el servidor que lo entrega no responde. No es tu conexión; avisa a quien administra el sistema.'
                      : 'Revisa tu conexión e inténtalo de nuevo.'),
              accion: sinGrado
                  ? null
                  : () => setState(() {
                        _futuro =
                            widget.repository.getComprehensionTrack(widget.studentId);
                      }),
            );
          }

          final track = snap.data!;
          // Un grado sin material no es un error: se dice tal cual, y se
          // aclara para qué grados sí hay, para que no parezca una falla.
          if (!track.hayContenido) {
            final otros = track.gradosConContenido.join('º, ');
            return _Aviso(
              icono: Icons.menu_book_outlined,
              titulo: 'Todavía no hay material para ${track.grade}º',
              detalle: otros.isEmpty
                  ? 'Aún no se ha cargado contenido de comprensión.'
                  : 'Por ahora hay ejercicios para ${otros}º.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: track.exercises.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (i == 0) return _Encabezado(grado: track.grade, total: track.exercises.length);
              return _Tarjeta(
                ejercicio: track.exercises[i - 1],
                onTap: () => _abrir(track.exercises[i - 1]),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _abrir(ComprehensionExerciseEntity resumen) async {
    // El catálogo trae solo el encabezado; el texto y las preguntas se piden
    // al abrir para no descargar 21 textos completos de una vez.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    ExerciseDetailEntity detalle;
    try {
      detalle = await widget.repository.getExerciseDetail(resumen.exerciseId);
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el ejercicio.')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);

    final preguntas = detalle.items
        .map(ChoiceQuestion.fromItem)
        .whereType<ChoiceQuestion>()
        .toList();
    final texto = detalle.texto ?? '';

    if (texto.trim().isEmpty || preguntas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este ejercicio no tiene contenido para mostrar.')),
      );
      return;
    }

    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => _EjercicioScreen(detalle: detalle, texto: texto, preguntas: preguntas),
    ));
  }
}

class _EjercicioScreen extends StatelessWidget {
  final ExerciseDetailEntity detalle;
  final String texto;
  final List<ChoiceQuestion> preguntas;

  const _EjercicioScreen({
    required this.detalle,
    required this.texto,
    required this.preguntas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(detalle.titulo), actions: const [ThemeToggleButton()]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(detalle.instruccion,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.mutedText, height: 1.45)),
          const SizedBox(height: 18),
          ComprehensionPlayer(
            texto: texto,
            preguntas: preguntas,
            usaTts: detalle.usaTts,
            autoevaluacion: detalle.autoevaluacion,
            metaPalabrasPorMinuto: detalle.metaPalabrasPorMinuto,
            onFinish: (accuracy, aciertos, total, ppm) {
              // La vía universal no alimenta la ruta adaptativa: no depende
              // del diagnóstico, así que no hay ruta que ajustar. El resultado
              // se le muestra al alumno y ahí termina.
            },
          ),
        ]),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final String grado;
  final int total;
  const _Encabezado({required this.grado, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$total ejercicios para ${grado}º',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Se pueden hacer en cualquier orden.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.mutedText)),
      ]),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final ComprehensionExerciseEntity ejercicio;
  final VoidCallback onTap;
  const _Tarjeta({required this.ejercicio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.menu_book_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ejercicio.titulo,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text('${ejercicio.totalPreguntas} preguntas',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.mutedText)),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.mutedText),
        ]),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback? accion;

  const _Aviso({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icono, size: 52, color: AppTheme.mutedText),
          const SizedBox(height: 16),
          Text(titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(detalle,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.mutedText)),
          if (accion != null) ...[
            const SizedBox(height: 18),
            ElevatedButton(onPressed: accion, child: const Text('Reintentar')),
          ],
        ]),
      ),
    );
  }
}
