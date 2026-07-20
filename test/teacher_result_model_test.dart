import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/data/models/screening_model.dart';

void main() {
  test('parsea alertas clínicas, descartar sensorial e índice de discrepancia', () {
    final r = TeacherResultModel.fromJson({
      'id': 'x', 'student_id': 's', 'score': 80.0, 'battery_mode': 'FULL',
      'risk_flags': [], 'enabled_module_codes': [],
      'alertas_clinicas': [
        {'item_code': 'h01_vision', 'tags': ['sensorial', 'vision'], 'certeza': 'confirmado'},
      ],
      'requiere_descartar_sensorial': true,
      'indice_discrepancia': 66.0,
    });
    expect(r.requiereDescartarSensorial, true);
    expect(r.indiceDiscrepancia, 66.0);
    expect(r.alertasClinicas.single.certeza, 'confirmado');
  });

  test('sin campos nuevos toma defaults seguros', () {
    final r = TeacherResultModel.fromJson({
      'id': 'x', 'student_id': 's', 'score': 10.0, 'battery_mode': 'QUICK',
      'risk_flags': [], 'enabled_module_codes': [],
    });
    // None y no 0: "no se preguntó" es distinto de "no hay discrepancia".
    expect(r.indiceDiscrepancia, isNull);
    expect(r.requiereDescartarSensorial, false);
    expect(r.alertasClinicas, isEmpty);
  });
}
