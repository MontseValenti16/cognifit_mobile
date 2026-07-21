import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/child/data/child_grid_games.dart';
import 'package:cognifit_mobile/features/child/presentation/screens/child_games_catalog_screen.dart';
import 'package:cognifit_mobile/features/child/presentation/screens/child_grid_game_screen.dart';

void main() {
  GridGame juego(String id, String question, GridCategory cat) => GridGame(
        id: id,
        sectionLabel: 'X',
        question: question,
        instruction: 'i',
        celdas: List<GridCell>.filled(20, const TextCell('a'))..[0] = const TextCell('b'),
        objetivos: const {0},
        explanation: 'e',
        categoria: cat,
      );

  testWidgets('agrupa por categoría y muestra los títulos de los juegos', (t) async {
    final juegos = [
      juego('A', 'Encuentra las b', GridCategory.buscaLetra),
      juego('B', 'Encuentra las da', GridCategory.silabas),
    ];
    await t.pumpWidget(MaterialApp(
      home: ChildGamesCatalogScreen(studentName: 'Ana', juegos: juegos),
    ));
    expect(find.text(nombreCategoria(GridCategory.buscaLetra)), findsOneWidget);
    expect(find.text(nombreCategoria(GridCategory.silabas)), findsOneWidget);
    expect(find.text('Encuentra las b'), findsOneWidget);
    expect(find.text('Encuentra las da'), findsOneWidget);
  });

  testWidgets('tocar un juego abre la cuadrícula con solo ese juego', (t) async {
    final juegos = [
      juego('A', 'Encuentra las b', GridCategory.buscaLetra),
      juego('B', 'Encuentra las da', GridCategory.silabas),
    ];
    await t.pumpWidget(MaterialApp(
      home: ChildGamesCatalogScreen(studentName: 'Ana', juegos: juegos),
    ));
    await t.tap(find.text('Encuentra las b'));
    await t.pumpAndSettle();
    final screen =
        t.widget<ChildGridGameScreen>(find.byType(ChildGridGameScreen));
    expect(screen.juegos.length, 1);
    expect(screen.juegos.single.id, 'A');
  });
}
