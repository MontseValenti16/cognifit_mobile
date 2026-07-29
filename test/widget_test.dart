import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cognifit_mobile/app.dart';

void main() {
  testWidgets('la app arranca sin excepciones y monta un MaterialApp', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CogniFitApp()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
