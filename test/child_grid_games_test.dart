/// El banco de cuadrículas se escribe a mano y es donde más fácil se cuela un
/// error: una casilla de menos, un objetivo mal contado, una consigna que pide
/// una letra que no está. Estas pruebas lo fijan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/child/data/child_exercises.dart';
import 'package:cognifit_mobile/features/child/data/child_grid_games.dart';
import 'package:cognifit_mobile/features/child/presentation/screens/child_grid_game_screen.dart';

void main() {
  _pruebasDePosicion();

  group('banco de cuadrículas', () {
    test('TODOS los juegos son de 5x4 = 20 casillas', () {
      for (final j in kTodosLosGridGames) {
        expect(j.celdas.length, 20, reason: '${j.id} no tiene 20 casillas');
        expect(j.columnas, 5, reason: '${j.id} no es de 5 columnas');
      }
    });

    test('cada juego tiene objetivos y también distractores', () {
      for (final j in kTodosLosGridGames) {
        expect(j.objetivos, isNotEmpty, reason: '${j.id} no tiene nada que buscar');
        expect(j.objetivos.length, lessThan(20),
            reason: '${j.id} es todo objetivos: no hay que discriminar nada');
      }
    });

    test('los índices objetivo caen dentro de la cuadrícula', () {
      for (final j in kTodosLosGridGames) {
        for (final i in j.objetivos) {
          expect(i, inInclusiveRange(0, j.celdas.length - 1),
              reason: '${j.id} apunta a la casilla $i, que no existe');
        }
      }
    });

    test('los objetivos son todas las casillas iguales entre sí', () {
      // Si una casilla igual a un objetivo quedara fuera, el niño la marcaría
      // con razón y se le contaría como error.
      for (final j in kGridGames) {
        final valorObjetivo = j.celdas[j.objetivos.first];
        for (var i = 0; i < j.celdas.length; i++) {
          if (j.celdas[i] == valorObjetivo) {
            expect(j.objetivos.contains(i), isTrue,
                reason: '${j.id}: la casilla $i es "$valorObjetivo" pero no cuenta como objetivo');
          }
        }
      }
    });

    test('no hay ids repetidos', () {
      final ids = kTodosLosGridGames.map((j) => j.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('hay variedad y progresión de dificultad', () {
      expect(kGridGames.length, greaterThanOrEqualTo(8));
      expect(kGridGames.map((j) => j.difficulty).toSet().length,
          greaterThan(1), reason: 'todas tienen la misma dificultad');
    });

    test('los 20 ejercicios originales quedaron convertidos a cuadrícula', () {
      // Ninguno se puede quedar en la mecánica de fila: se retiró.
      final convertidos = gridGamesDesdeEjercicios(kChildExercises);
      expect(convertidos.length, kChildExercises.length);
      for (final j in convertidos) {
        expect(j.objetivos.length, 1,
            reason: '${j.id}: "cuál es diferente" debe tener una sola distinta');
        expect(j.celdas.length, 20);
      }
    });

    test('en los convertidos, la distinta es la única que no se repite', () {
      for (final j in gridGamesDesdeEjercicios(kChildExercises)) {
        final pos = j.objetivos.first;
        final distinta = j.celdas[pos];
        final iguales = j.celdas.where((c) => c == distinta).length;
        expect(iguales, 1, reason: '${j.id}: "$distinta" aparece $iguales veces');
      }
    });

    test('el conjunto completo suma los dos tipos de juego', () {
      expect(kTodosLosGridGames.length,
          kGridGames.length + kChildExercises.length);
    });

    test('todos los juegos previos son de celdas de texto y tienen categoría', () {
      for (final j in kTodosLosGridGames) {
        for (final c in j.celdas) {
          expect(c, isA<TextCell>(), reason: '${j.id} tiene una celda no-texto');
        }
      }
      // Las categorías previas: letra (banco a mano) y "cuál es diferente".
      final cats = kTodosLosGridGames.map((j) => j.categoria).toSet();
      expect(cats, contains(GridCategory.buscaLetra));
      expect(cats, contains(GridCategory.cualEsDiferente));
    });
  });

  group('pantalla', () {
    final unJuego = [
      GridGame(
        id: 'T',
        sectionLabel: 'PRUEBA',
        question: 'Encuentra las b',
        instruction: 'Toca cada b.',
        celdas: const [
          TextCell('b'), TextCell('d'), TextCell('d'), TextCell('b'), TextCell('d'),
          TextCell('d'), TextCell('d'), TextCell('d'), TextCell('d'), TextCell('d'),
          TextCell('d'), TextCell('d'), TextCell('d'), TextCell('d'), TextCell('d'),
          TextCell('d'), TextCell('d'), TextCell('d'), TextCell('d'), TextCell('d'),
        ],
        objetivos: const {0, 3},
        explanation: 'La b tiene la panza a la derecha.',
        categoria: GridCategory.buscaLetra,
      ),
    ];

    testWidgets('no se puede revisar sin marcar nada', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChildGridGameScreen(studentName: 'Ana', juegos: unJuego),
      ));
      final boton = tester.widget<ElevatedButton>(
        find.ancestor(of: find.text('Revisar'), matching: find.byType(ElevatedButton)));
      expect(boton.onPressed, isNull, reason: 'debe estar deshabilitado');
    });

    testWidgets('cuenta las marcadas sin decir si están bien', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChildGridGameScreen(studentName: 'Ana', juegos: unJuego),
      ));
      await tester.tap(find.text('b').first);
      await tester.pump();
      // Adelantar si acertó volvería el juego ensayo y error.
      expect(find.text('Marcadas: 1'), findsOneWidget);
    });

    testWidgets('distingue omitir de marcar de más', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChildGridGameScreen(studentName: 'Ana', juegos: unJuego),
      ));
      // Marca una 'd' (error) y deja las dos 'b' sin marcar (omisiones).
      await tester.tap(find.text('d').first);
      await tester.pump();
      await tester.tap(find.text('Revisar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Se te pasaron 2'), findsOneWidget);
      expect(find.textContaining('marcaste 1 de más'), findsOneWidget);
    });

    testWidgets('marcar todas las correctas da retroalimentación positiva',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChildGridGameScreen(studentName: 'Ana', juegos: unJuego),
      ));
      await tester.tap(find.text('b').at(0));
      await tester.pump();
      await tester.tap(find.text('b').at(1));
      await tester.pump();
      await tester.tap(find.text('Revisar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Se te pas'), findsNothing);
      expect(find.textContaining('de más'), findsNothing);
      expect(find.text('Terminar'), findsOneWidget);
    });
  });
}

/// La posición de la casilla distinta importa: si cae en la primera fila el
/// alumno la encuentra sin buscar, porque ahí empieza a leer.
void _pruebasDePosicion() {
  group('posición de la casilla distinta', () {
    test('nunca cae en la primera fila', () {
      for (final j in gridGamesDesdeEjercicios(kChildExercises)) {
        final pos = j.objetivos.first;
        expect(pos, greaterThanOrEqualTo(5),
            reason: '${j.id}: la distinta está en la casilla $pos, '
                'que se ve sin buscar');
      }
    });

    test('dos ejercicios seguidos no la ponen en el mismo lugar', () {
      final juegos = gridGamesDesdeEjercicios(kChildExercises);
      for (var i = 1; i < juegos.length; i++) {
        expect(juegos[i].objetivos.first,
            isNot(equals(juegos[i - 1].objetivos.first)),
            reason: 'los juegos ${i - 1} y $i repiten posición seguidos');
      }
    });

    test('se usan varias posiciones distintas', () {
      final usadas = gridGamesDesdeEjercicios(kChildExercises)
          .map((j) => j.objetivos.first)
          .toSet();
      expect(usadas.length, greaterThanOrEqualTo(10),
          reason: 'se repite demasiado el mismo lugar: $usadas');
    });
  });
}
