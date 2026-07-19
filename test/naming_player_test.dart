/// La denominación rápida (RAN) estuvo sin jugarse porque su contenido
/// apuntaba a un banco inexistente y porque se asumía que necesitaba
/// reconocimiento de voz. La medida real es el tiempo total de nombrar la
/// rejilla, que la app sí puede cronometrar.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/intervention/presentation/widgets/naming_player.dart';
import 'package:cognifit_mobile/features/intervention/data/models/intervention_model.dart';

/// Reloj de prueba: informa un tiempo fijo, ya que `pump()` no mueve el reloj
/// del sistema que usa un Stopwatch real.
class _RelojFijo implements Stopwatch {
  @override
  final int elapsedMilliseconds;
  bool _corriendo = false;
  _RelojFijo(this.elapsedMilliseconds);

  @override
  void start() => _corriendo = true;
  @override
  void stop() => _corriendo = false;
  @override
  void reset() {}
  @override
  bool get isRunning => _corriendo;

  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  testWidgets('cronometra y devuelve el tiempo al terminar', (tester) async {
    double? accuracy;
    int? segundos;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: NamingPlayer(
            grid: const ['m', 's', 'a', 'p', 'l'],
            kind: NamingKind.letras,
            crearReloj: () => _RelojFijo(12400),
            onFinish: (a, s) {
              accuracy = a;
              segundos = s;
            },
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Empezar'));
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.text('Terminé'));
    await tester.pump();

    expect(segundos, 12, reason: '12.4 s se redondea a 12');
    // Sin norma de referencia se reporta el punto medio: inventar un umbral
    // decidiría si un alumno sube de nivel sin base para ello.
    expect(accuracy, 0.5);
  });

  test('el modelo lee `textos` en plural, no solo `texto`', () {
    // TTS_lectura_guiada_N1 guarda sus frases en `textos`; leer solo `texto`
    // dejaba el ejercicio vacío aunque el servicio sí las enviaba.
    final d = ExerciseDetailModel.fromJson({
      'exercise_id': 'TTS_lectura_guiada_N1',
      'tipo': 'lectura',
      'titulo': 'Lee con apoyo de voz',
      'instruccion': 'Lee.',
      'usa_tts': true,
      'usa_stt': true,
      'nivel': 1,
      'items': [],
      'textos': ['Mi mamá me mima.', 'El sol sale por las mañanas.'],
    });

    expect(d.texto, isNotNull);
    expect(d.texto, contains('Mi mamá me mima.'));
    expect(d.texto, contains('El sol sale por las mañanas.'));
  });

  test('el modelo lee la rejilla y sus tablas de apoyo', () {
    final d = ExerciseDetailModel.fromJson({
      'exercise_id': 'DEN_rapid_colores_N1',
      'tipo': 'denominacion_rapida',
      'subtipo': 'colores',
      'titulo': 'Nombra los colores',
      'instruccion': 'Nombra.',
      'usa_tts': false,
      'usa_stt': true,
      'nivel': 1,
      'items': [],
      'grid': ['rojo', 'azul', 'rojo'],
      'grid_columnas': 5,
      'paleta': {'rojo': '#E53935', 'azul': '#1E88E5'},
    });

    expect(d.grid.length, 3);
    expect(d.subtipo, 'colores');
    expect(d.gridColumnas, 5);
    expect(d.paleta['rojo'], '#E53935');
  });
}
