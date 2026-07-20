import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/presentation/viewmodels/tests_viewmodel.dart';

void main() {
  test('gradeDesdeGrupo resuelve el grado por groupId, o null si no está', () {
    final mapa = {'g1': 6, 'g2': 1};
    expect(gradeDesdeGrupo('g1', mapa), 6);
    expect(gradeDesdeGrupo('g2', mapa), 1);
    // Grupo desconocido: null, para que el backend caiga al cuestionario del
    // primer ciclo (el más chico y el que menos supone) en vez de romper.
    expect(gradeDesdeGrupo('desconocido', mapa), isNull);
  });
}
