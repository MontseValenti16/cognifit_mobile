import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/domain/entities/screening_entity.dart';
import 'package:cognifit_mobile/features/tests/presentation/viewmodels/tests_viewmodel.dart';

void main() {
  test('itemsPorCategoria agrupa respetando el orden RIESGO/HISTORIA/DISCREPANCIA', () {
    final items = [
      const TeacherItemEntity(itemCode: 'q01', prompt: 'a', weight: 14, tags: [], scale: {}, categoria: 'RIESGO'),
      const TeacherItemEntity(itemCode: 'h01', prompt: 'b', weight: 0, tags: [], scale: {}, categoria: 'HISTORIA_CLINICA'),
      const TeacherItemEntity(itemCode: 'd01', prompt: 'c', weight: 0, tags: [], scale: {}, categoria: 'DISCREPANCIA'),
    ];
    final agrupado = agruparPorCategoria(items);
    expect(agrupado.keys.toList(), ['HISTORIA_CLINICA', 'RIESGO', 'DISCREPANCIA']);
    expect(agrupado['RIESGO']!.single.itemCode, 'q01');
  });
}
