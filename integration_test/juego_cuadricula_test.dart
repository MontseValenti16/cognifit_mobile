/// Captura el juego de cuadrícula corriendo en el dispositivo.
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:cognifit_mobile/features/child/data/child_exercises.dart';
import 'package:cognifit_mobile/features/child/data/child_grid_games.dart';
import 'package:cognifit_mobile/features/child/presentation/screens/child_grid_game_screen.dart';

late IntegrationTestWidgetsFlutterBinding binding;

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capturas del juego de cuadricula', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ChildGridGameScreen(studentName: 'Ana')),
    );
    await tester.pumpAndSettle();

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    await binding.takeScreenshot('10_cuadricula_inicio');

    // Marca algunas b (aciertos) y una d (error) para mostrar la correccion.
    await tester.tap(find.text('b').at(0));
    await tester.pump();
    await tester.tap(find.text('b').at(1));
    await tester.pump();
    await tester.tap(find.text('d').at(0));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('11_cuadricula_marcando');

    await tester.tap(find.text('Revisar'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('12_cuadricula_corregida');

  });

  testWidgets('captura de un juego convertido de "cual es diferente"', (tester) async {
    // Se monta directo con los convertidos: 19 iguales y una distinta, que es
    // el caso visualmente mas cargado.
    await tester.pumpWidget(MaterialApp(
      home: ChildGridGameScreen(
        studentName: 'Ana',
        juegos: gridGamesDesdeEjercicios(kChildExercises).take(1).toList(),
      ),
    ));
    await tester.pumpAndSettle();

    // La conversion de superficie no se hereda entre pruebas: cada testWidgets
    // que capture tiene que pedirla de nuevo.
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    await binding.takeScreenshot('13_cuadricula_cual_es_diferente');
  });
}
