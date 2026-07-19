/// El catálogo de comprensión llega del API y se parsea acá. Un grado sin
/// contenido responde 200 con lista vacía: si el parseo lo tratara como error,
/// la pantalla mostraría "falló la conexión" cuando en realidad solo falta
/// material para ese grado.
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/intervention/data/models/intervention_model.dart';

void main() {
  test('parsea el catálogo de un grado con contenido', () {
    final t = ComprehensionTrackModel.fromJson({
      'grade': '6',
      'via': 'universal_grado',
      'total': 2,
      'exercises': [
        {
          'exercise_id': 'COMP6_verificar_afirmaciones_N1',
          'titulo': '¿Eso lo dice el texto?',
          'subtipo': 'verificacion',
          'instruccion': 'Lee el texto.',
          'modalidad': 'lectura_opciones',
          'total_preguntas': 5,
        },
        {
          'exercise_id': 'COMP6_autoevaluacion_N1',
          'titulo': '¿Qué tanto crees que entendiste?',
          'subtipo': 'metacognicion',
          'instruccion': 'Lee el texto.',
          'modalidad': 'lectura_opciones',
          'total_preguntas': 4,
        },
      ],
      'grados_con_contenido': ['4', '5', '6'],
    });

    expect(t.grade, '6');
    expect(t.hayContenido, isTrue);
    expect(t.exercises.length, 2);
    expect(t.exercises.first.totalPreguntas, 5);
    expect(t.gradosConContenido, ['4', '5', '6']);
  });

  test('un grado sin contenido no es un error', () {
    final t = ComprehensionTrackModel.fromJson({
      'grade': '1',
      'total': 0,
      'exercises': [],
      'grados_con_contenido': ['4', '5', '6'],
    });

    expect(t.hayContenido, isFalse);
    expect(t.exercises, isEmpty);
    // La pantalla usa esto para decir para qué grados sí hay material.
    expect(t.gradosConContenido, ['4', '5', '6']);
  });

  test('tolera campos ausentes sin reventar', () {
    final t = ComprehensionTrackModel.fromJson({'grade': '3'});
    expect(t.hayContenido, isFalse);
    expect(t.gradosConContenido, isEmpty);
  });
}
