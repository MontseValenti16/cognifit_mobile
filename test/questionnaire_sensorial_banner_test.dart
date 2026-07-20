import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/presentation/widgets/teacher_questionnaire_widgets.dart';

void main() {
  testWidgets('el banner sensorial explica que hay que descartar antes de concluir', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(body: SensorialAlertBanner()),
    ));
    expect(find.textContaining('visión'), findsOneWidget);
    expect(find.textContaining('no puede leerse como un diagnóstico'), findsOneWidget);
  });
}
