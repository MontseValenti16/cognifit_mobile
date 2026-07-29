/// Smoke test de arranque.
///
/// Antes este archivo era la plantilla de `flutter create` — buscaba un
/// contador que esta app nunca tuvo, así que fallaba siempre y dejaba
/// `flutter test` en rojo de forma permanente, lo que esconde fallas reales.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cognifit_mobile/app.dart';

void main() {
  testWidgets('la app arranca sin excepciones y monta un MaterialApp', (tester) async {
    // ProviderScope: CogniFitApp es un ConsumerWidget y necesita el
    // contenedor de Riverpod como ancestro, igual que en runApp() real.
    await tester.pumpWidget(const ProviderScope(child: CogniFitApp()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
