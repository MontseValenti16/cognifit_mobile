import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/data/models/screening_model.dart';

void main() {
  test('parsea una entrada del calendario', () {
    final e = CalendarioEntryModel.fromJson({
      'student_id': 's1', 'student_name': 'Ana López', 'grade': 6,
      'que_toca': 'MONITOREO', 'ult_monitoreo': '2026-06-01T00:00:00Z',
      'ult_bateria': null, 'sin_linea_base': false,
    });
    expect(e.studentName, 'Ana López');
    expect(e.queToca, 'MONITOREO');
    expect(e.grade, 6);
    expect(e.ultBateria, isNull);
  });
}
