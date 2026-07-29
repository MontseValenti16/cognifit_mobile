import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/security/screen_security.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenSecurity.enable();
  await ConnectivityService.instance.initialize();
  await ThemeController.instance.load();
  // ProviderScope es la raíz del árbol de Riverpod: sin esto ningún
  // ref.watch/ref.read de la app tiene de dónde leer.
  runApp(const ProviderScope(child: CogniFitApp()));
}
