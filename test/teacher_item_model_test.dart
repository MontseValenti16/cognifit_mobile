import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/data/models/screening_model.dart';

void main() {
  test('parsea categoria y ciclos, con defaults', () {
    final hist = TeacherItemModel.fromJson({
      'item_code': 'h01_vision', 'prompt': '¿Ve bien?', 'weight': 0,
      'tags': ['sensorial', 'vision'], 'categoria': 'HISTORIA_CLINICA',
      'ciclos': [1, 2, 3],
      'scale': [{'label': 'No', 'value': 0}, {'label': 'Sí', 'value': 1}],
    });
    expect(hist.categoria, 'HISTORIA_CLINICA');
    expect(hist.ciclos, [1, 2, 3]);

    // Un ítem viejo sin los campos toma los defaults, para no romper si el
    // backend aún no los envía en algún entorno.
    final viejo = TeacherItemModel.fromJson({
      'item_code': 'q01', 'prompt': 'x', 'weight': 14, 'tags': [],
      'scale': [{'label': 'Nunca', 'value': 0}],
    });
    expect(viejo.categoria, 'RIESGO');
    expect(viejo.ciclos, [1, 2, 3]);
  });
}
