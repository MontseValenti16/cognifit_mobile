import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/domain/entities/screening_entity.dart';
import 'package:cognifit_mobile/features/tests/presentation/widgets/teacher_questionnaire_widgets.dart';

TeacherResultEntity _result({double? discrepancia}) => TeacherResultEntity(
      id: 'r1',
      studentId: 's1',
      score: 42,
      batteryMode: 'FULL',
      riskFlags: const [],
      enabledModuleCodes: const [],
      indiceDiscrepancia: discrepancia,
    );

void main() {
  testWidgets('la tarjeta muestra el índice de discrepancia cuando existe', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: TeacherResultCard(result: _result(discrepancia: 66))),
    ));
    expect(find.textContaining('Índice de discrepancia: 66'), findsOneWidget);
  });

  testWidgets('la tarjeta no menciona la discrepancia cuando el ciclo no la trae', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(body: TeacherResultCard(result: _result(discrepancia: null))),
    ));
    expect(find.textContaining('Índice de discrepancia'), findsNothing);
  });
}
