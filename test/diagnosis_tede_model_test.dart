import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/data/models/screening_model.dart';

void main() {
  test('parsea los dos subtests del TEDE cuando vienen', () {
    final d = DiagnosisModel.fromJson({
      'subtype': 'fonologico', 'severity': 'moderado',
      'tede_nivel_lector': {
        'percentil_por_grado': 5, 'percentil_por_edad': 11,
        'puntaje_escala_tede': 30, 'escalado': true,
      },
      'tede_errores_especificos': {
        'percentil_por_grado': 2, 'percentil_por_edad': 3,
        'puntaje_escala_tede': 0, 'escalado': false,
      },
    });
    expect(d.tedeNivelLector!.percentilPorGrado, 5);
    expect(d.tedeNivelLector!.escalado, true);
    expect(d.tedeErroresEspecificos!.percentilPorGrado, 2);
  });

  test('sin percentiles quedan en null', () {
    final d = DiagnosisModel.fromJson({'subtype': 'sin_riesgo', 'severity': 'ninguna'});
    expect(d.tedeNivelLector, isNull);
    expect(d.tedeErroresEspecificos, isNull);
  });
}
