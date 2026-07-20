/// Driver de las pruebas de integración.
///
/// La prueba corre en el teléfono, que no puede escribir en el sistema de
/// archivos del proyecto. `onScreenshot` se ejecuta del lado de la
/// computadora: recibe los bytes que la app capturó y los guarda en disco.
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String nombre, List<int> bytes, [Map<String, Object?>? args]) async {
      final dir = Directory('build/capturas')..createSync(recursive: true);
      final archivo = File('${dir.path}/$nombre.png')..writeAsBytesSync(bytes);
      stdout.writeln('captura -> ${archivo.path} (${bytes.length} bytes)');
      return true;
    },
  );
}
