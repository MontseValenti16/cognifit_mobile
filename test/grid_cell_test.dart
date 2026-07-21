import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/child/data/child_grid_games.dart';

void main() {
  test('FigureSpec compara por valor (forma, giro, espejo)', () {
    const a = FigureSpec(FiguraForma.pez, cuartosDeGiro: 1, espejada: true);
    const b = FigureSpec(FiguraForma.pez, cuartosDeGiro: 1, espejada: true);
    const c = FigureSpec(FiguraForma.pez, cuartosDeGiro: 1, espejada: false);
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
    expect(a.hashCode, equals(b.hashCode));
  });

  test('TextCell expone su texto como etiqueta accesible', () {
    const celda = TextCell('b');
    expect(celda.semanticLabel, 'b');
  });

  test('FigureCell describe su orientación en la etiqueta accesible', () {
    const celda = FigureCell(FigureSpec(FiguraForma.pez, espejada: true));
    expect(celda.semanticLabel, contains('pez'));
  });
}
