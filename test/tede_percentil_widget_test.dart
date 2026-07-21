import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/domain/entities/screening_entity.dart';
import 'package:cognifit_mobile/features/student_profile/presentation/screens/student_profile_screen.dart';

void main() {
  testWidgets('la tarjeta TEDE muestra el percentil y avisa cuando es escalado', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: TedePercentilCard(
        nivelLector: const TedePercentil(percentilPorGrado: 5, puntajeEscalaTede: 30, escalado: true),
        erroresEspecificos: const TedePercentil(percentilPorGrado: 20, puntajeEscalaTede: 55, escalado: false),
      )),
    ));
    expect(find.textContaining('percentil 5'), findsOneWidget);
    expect(find.textContaining('orientativo'), findsOneWidget); // por el escalado
  });
}
