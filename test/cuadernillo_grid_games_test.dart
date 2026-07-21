import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/child/data/child_grid_games.dart';
import 'package:cognifit_mobile/features/child/data/cuadernillo_grid_games.dart';

void main() {
  group('juegos de orientación', () {
    test('cada juego de orientación trae modelo y solo celdas de figura', () {
      for (final j in kJuegosOrientacion) {
        expect(j.categoria, GridCategory.orientacion, reason: j.id);
        expect(j.modelo, isNotNull, reason: '${j.id} no tiene modelo');
        for (final c in j.celdas) {
          expect(c, isA<FigureCell>(), reason: '${j.id} tiene celda no-figura');
        }
      }
    });

    test('los objetivos son exactamente las figuras iguales al modelo', () {
      for (final j in kJuegosOrientacion) {
        final iguales = <int>{};
        for (var i = 0; i < j.celdas.length; i++) {
          final c = j.celdas[i] as FigureCell;
          if (c.figura == j.modelo) iguales.add(i);
        }
        expect(j.objetivos, equals(iguales),
            reason: '${j.id}: objetivos no coinciden con las iguales al modelo');
      }
    });

    test('hay distractores espejados o girados (no todo es igual al modelo)', () {
      for (final j in kJuegosOrientacion) {
        expect(j.objetivos.length, lessThan(20), reason: '${j.id} no discrimina nada');
      }
    });

    test('los juegos de orientación están en kTodosLosGridGames', () {
      final ids = kTodosLosGridGames.map((j) => j.id).toSet();
      for (final j in kJuegosOrientacion) {
        expect(ids, contains(j.id));
      }
    });
  });
}
