/// La vía de comprensión es el único caso del banco que trae texto Y preguntas
/// a la vez. El despacho de reproductores revisaba `texto` primero, así que un
/// ejercicio de comprensión caía en ReadingPlayer y sus preguntas no se
/// mostraban nunca. Estas pruebas fijan ese comportamiento.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/intervention/presentation/widgets/choice_player.dart';
import 'package:cognifit_mobile/features/intervention/presentation/widgets/comprehension_player.dart';

const _texto = 'Las abejas meliponas no tienen aguijón. Producen menos miel.';

final _preguntas = [
  const ChoiceQuestion(
    enunciado: '¿Las meliponas tienen aguijón?',
    opciones: ['No', 'Sí'],
    correcta: 'No',
  ),
  const ChoiceQuestion(
    enunciado: '¿Producen mucha o poca miel?',
    opciones: ['Poca', 'Mucha'],
    correcta: 'Poca',
  ),
];

Future<void> _montar(WidgetTester tester, ComprehensionPlayer player) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: player)),
  ));
}

void main() {
  testWidgets('el texto sigue visible mientras se responde', (tester) async {
    // Ocultarlo mediría memoria, no comprensión.
    await _montar(tester, ComprehensionPlayer(
      texto: _texto,
      preguntas: _preguntas,
      onFinish: (_, __, ___, ____) {},
    ));

    expect(find.textContaining('meliponas'), findsOneWidget);
    await tester.tap(find.text('Ya leí, quiero responder'));
    await tester.pumpAndSettle();

    expect(find.text('¿Las meliponas tienen aguijón?'), findsOneWidget);
    expect(find.text('Ver el texto otra vez'), findsOneWidget,
        reason: 'el alumno debe poder volver al texto');
  });

  testWidgets('reporta la precisión de comprensión, no la velocidad',
      (tester) async {
    double? accuracy;
    int? aciertos;
    int? ppm;

    await _montar(tester, ComprehensionPlayer(
      texto: _texto,
      preguntas: _preguntas,
      metaPalabrasPorMinuto: 135,
      onFinish: (a, ac, _, p) {
        accuracy = a;
        aciertos = ac;
        ppm = p;
      },
    ));

    await tester.tap(find.text('Ya leí, quiero responder'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('No'));            // correcta
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(find.text('Mucha'));         // incorrecta
    await tester.pump(const Duration(milliseconds: 1000));

    expect(aciertos, 1);
    expect(accuracy, 0.5, reason: '1 de 2 preguntas, no palabras por minuto');
    expect(ppm, isNotNull, reason: 'las ppm se reportan aparte, como metadato');
  });

  testWidgets('la autoevaluación pregunta antes y compara al final',
      (tester) async {
    await _montar(tester, ComprehensionPlayer(
      texto: _texto,
      preguntas: _preguntas,
      autoevaluacion: true,
      onFinish: (_, __, ___, ____) {},
    ));

    await tester.tap(find.text('Ya leí, quiero responder'));
    await tester.pumpAndSettle();

    expect(find.textContaining('¿cuántas crees que vas a acertar?'), findsOneWidget);
    await tester.tap(find.text('2'));  // predice 2
    await tester.pumpAndSettle();

    await tester.tap(find.text('No'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(find.text('Mucha'));
    await tester.pump(const Duration(milliseconds: 1000));

    // Acertó 1 habiendo predicho 2.
    expect(find.textContaining('Esperabas más'), findsOneWidget);
    expect(find.text('Habías dicho 2'), findsOneWidget);
  });

  testWidgets('sin autoevaluación no se pregunta la predicción', (tester) async {
    await _montar(tester, ComprehensionPlayer(
      texto: _texto,
      preguntas: _preguntas,
      onFinish: (_, __, ___, ____) {},
    ));

    await tester.tap(find.text('Ya leí, quiero responder'));
    await tester.pumpAndSettle();
    expect(find.textContaining('crees que vas a acertar'), findsNothing);
  });
}
