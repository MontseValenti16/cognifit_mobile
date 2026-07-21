import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/domain/entities/screening_entity.dart';
import 'package:cognifit_mobile/features/tests/presentation/screens/calendario_screen.dart';

void main() {
  testWidgets('lista lo que le toca a cada alumno, con la línea base primero', (t) async {
    final entradas = [
      const CalendarioEntryEntity(studentId: 's1', studentName: 'Ana', grade: 1,
          queToca: 'BATERIA_INICIAL', sinLineaBase: true),
      const CalendarioEntryEntity(studentId: 's2', studentName: 'Beto', grade: 6,
          queToca: 'MONITOREO'),
    ];
    await t.pumpWidget(MaterialApp(home: CalendarioScreen(entradas: entradas)));
    await t.pumpAndSettle();
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Beto'), findsOneWidget);
    expect(find.textContaining('Primera evaluación'), findsOneWidget);
  });
}
