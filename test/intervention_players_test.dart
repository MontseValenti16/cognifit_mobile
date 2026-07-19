/// Los reproductores se alimentan del banco de intervención, que NO es
/// homogéneo: 13 esquemas de ítem distintos y 13 ejercicios que no traen
/// ítems sino texto corrido. Estas pruebas usan las formas reales del banco
/// para que un esquema nuevo no rompa la pantalla en silencio.
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/intervention/presentation/widgets/choice_player.dart';

void main() {
  group('ChoiceQuestion.fromItem con los esquemas reales del banco', () {
    test('discriminación visual: {estimulo, opciones, correcta}', () {
      final q = ChoiceQuestion.fromItem({
        'estimulo': 'b',
        'opciones': ['b', 'd'],
        'correcta': 'b',
      });
      expect(q, isNotNull);
      expect(q!.opciones, ['b', 'd']);
      expect(q.correcta, 'b');
    });

    test('rimas: {palabra_base, opciones, correcta}', () {
      final q = ChoiceQuestion.fromItem({
        'palabra_base': 'gato',
        'opciones': ['pato', 'perro'],
        'correcta': 'pato',
      });
      expect(q!.enunciado, 'gato');
      expect(q.correcta, 'pato');
    });

    test('memoria de palabras: {palabra, distractor_1, distractor_2}', () {
      final q = ChoiceQuestion.fromItem({
        'palabra': 'casa',
        'distractor_1': 'caza',
        'distractor_2': 'cosa',
      });
      expect(q!.correcta, 'casa');
      expect(q.opciones, containsAll(['casa', 'caza', 'cosa']));
    });

    test('parejas: {par, son_iguales} se vuelve iguales/distintas', () {
      final iguales = ChoiceQuestion.fromItem({
        'par': ['sol', 'sol'],
        'son_iguales': true,
      });
      expect(iguales!.correcta, 'Iguales');

      final distintas = ChoiceQuestion.fromItem({
        'par': ['sol', 'sal'],
        'son_iguales': false,
      });
      expect(distintas!.correcta, 'Distintas');
    });

    test('conteo de sílabas: {palabra, silabas} ofrece números', () {
      final q = ChoiceQuestion.fromItem({'palabra': 'mariposa', 'silabas': 4});
      expect(q!.enunciado, 'mariposa');
      expect(q.correcta, '4');
      expect(q.opciones, contains('4'));
    });

    test('devuelve null para lo que no es de opciones (voz, trazo)', () {
      // Ejercicio de voz: solo trae el target a leer.
      expect(ChoiceQuestion.fromItem({'target': 'mibo'}), isNull);
      // Trazo sobre canvas.
      expect(
        ChoiceQuestion.fromItem({'letra': 'b', 'descripcion_trazo': 'palito y panza'}),
        isNull,
        reason: 'sin reproductor todavía: debe caer a calificación manual, no romperse',
      );
    });
  });
}
