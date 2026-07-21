import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/child/data/cuadernillo_grid_games.dart';
import 'package:cognifit_mobile/features/child/presentation/screens/child_grid_game_screen.dart';
import 'package:cognifit_mobile/features/child/presentation/widgets/figura_painter.dart';

void main() {
  testWidgets('las figuras de un juego de orientación se dibujan con tamaño real',
      (t) async {
    await t.pumpWidget(MaterialApp(
      home: ChildGridGameScreen(
        studentName: 'Ana',
        juegos: [kJuegosOrientacion.first],
      ),
    ));
    await t.pumpAndSettle();

    // Al menos las 20 casillas + el modelo.
    final figuras = find.byType(FiguraView);
    expect(figuras, findsWidgets);

    // Ninguna FiguraView de la cuadrícula debe medir 0x0.
    var conTamano = 0;
    for (final e in figuras.evaluate()) {
      final size = e.size;
      if (size != null && size.width > 1 && size.height > 1) conTamano++;
    }
    expect(conTamano, greaterThanOrEqualTo(20),
        reason: 'las figuras de la cuadrícula colapsaron a 0x0');
  });
}
