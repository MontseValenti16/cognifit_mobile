import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/child/data/child_grid_games.dart';
import 'package:cognifit_mobile/features/child/presentation/widgets/figura_painter.dart';

void main() {
  testWidgets('FiguraView pinta cualquier forma/orientación sin lanzar', (t) async {
    for (final forma in FiguraForma.values) {
      for (final espejada in [false, true]) {
        for (var giro = 0; giro < 4; giro++) {
          await t.pumpWidget(MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: FiguraView(
                    figura: FigureSpec(forma, cuartosDeGiro: giro, espejada: espejada),
                  ),
                ),
              ),
            ),
          ));
          expect(find.byType(CustomPaint), findsWidgets);
        }
      }
    }
  });
}
