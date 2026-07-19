/// Los ítems de discriminación visual (M10_VD) traen las opciones dentro del
/// propio estímulo ("b|b|d|b"). Sin parsearlas el niño veía el texto crudo,
/// que es la razón por la que ese módulo estuvo fuera de la batería.
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/exercise/presentation/widgets/exercise_widgets.dart';

void main() {
  test('parsea las opciones reales del banco M10_VD', () {
    expect(MultipleChoiceAnswer.parseOptions('b|b|d|b'), ['b', 'b', 'd', 'b']);
    expect(MultipleChoiceAnswer.parseOptions('p|p|q|p'), ['p', 'p', 'q', 'p']);
  });

  test('un estimulo normal NO se trata como opcion multiple', () {
    expect(MultipleChoiceAnswer.parseOptions('mariposa'), isEmpty);
    expect(MultipleChoiceAnswer.parseOptions('¿Cuántas sílabas tiene "casa"?'), isEmpty);
  });

  test('tolera espacios y separadores vacios', () {
    expect(MultipleChoiceAnswer.parseOptions('b | d |  | b'), ['b', 'd', 'b']);
  });
}
