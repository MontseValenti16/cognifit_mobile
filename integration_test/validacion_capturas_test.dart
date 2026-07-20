/// Genera las capturas de evidencia de la validación del cliente, corriendo la
/// app real en el dispositivo.
///
/// Se usa una prueba de integración y no automatización a nivel del sistema
/// operativo: los toques se resuelven dentro del árbol de widgets de la propia
/// app, así que no pueden caer sobre otra aplicación del teléfono.
///
/// Ejecutar con:
///   flutter test integration_test/validacion_capturas_test.dart -d <device>
///
/// Las imágenes quedan en `build/capturas/`.
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:cognifit_mobile/core/validation/input_rules.dart';

late IntegrationTestWidgetsFlutterBinding binding;

/// Pide la captura. Los bytes viajan al driver, que corre en la computadora y
/// es quien los escribe a disco: el telefono no puede escribir en el proyecto.
Future<void> _capturar(WidgetTester tester, String nombre) async {
  await tester.pumpAndSettle();
  await binding.takeScreenshot(nombre);
}

/// Pantalla mínima que monta los mismos validadores que usa la app, para
/// aislarlos de la navegación y del estado de sesión. Lo que se fotografía es
/// el comportamiento real de `Validators`, no una imitación.
class _DemoValidacion extends StatefulWidget {
  const _DemoValidacion();

  @override
  State<_DemoValidacion> createState() => _DemoValidacionState();
}

class _DemoValidacionState extends State<_DemoValidacion> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF5B4BDB)),
      home: Scaffold(
        appBar: AppBar(title: const Text('Registro de institución')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _correo,
                decoration: const InputDecoration(
                  labelText: 'Correo del administrador',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.correo,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña (mín. 8 caracteres)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validators.passwordNueva(
                  v,
                  minimo: InputRules.passwordMinInstitucion,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _formKey.currentState?.validate(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Registrar escuela'),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capturas de la validación del cliente', (tester) async {
    await tester.pumpWidget(const _DemoValidacion());
    await tester.pumpAndSettle();

    // En Android hay que convertir la superficie de Flutter a imagen antes de
    // poder capturarla; sin esto `takeScreenshot` falla.
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    await _capturar(tester, '01_formulario_vacio');

    // 1. Correo sin dominio -> el validador lo rechaza.
    await tester.enterText(find.byType(TextFormField).first, 'director@escuela');
    await tester.pumpAndSettle();
    await _capturar(tester, '02_correo_invalido');

    // 2. Contraseña por debajo del mínimo del servidor (8).
    await tester.enterText(find.byType(TextFormField).last, 'corta');
    await tester.pumpAndSettle();
    await _capturar(tester, '03_password_corta');

    // 3. Ambos corregidos: los mensajes desaparecen.
    await tester.enterText(find.byType(TextFormField).first, 'director@escuela.mx');
    await tester.enterText(find.byType(TextFormField).last, 'clave-seguraaa');
    await tester.pumpAndSettle();
    await _capturar(tester, '04_valido');

    expect(find.text('Al correo le falta el dominio, como @escuela.mx'), findsNothing);
  });
}
