import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/security/screen_security.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenSecurity.enable();
  await ConnectivityService.instance.initialize();
  await ThemeController.instance.load();
  runApp(const CogniFitApp());
}

class CogniFitApp extends StatelessWidget {
  const CogniFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se escucha ThemeController aquí, en la raíz: al cambiar de modo esto
    // reconstruye MaterialApp entero, lo que en cascada vuelve a invocar
    // build() en la pantalla actual — y con ella, cada AppTheme.xxx que lea
    // se resuelve de nuevo con el modo ya actualizado. Ninguna pantalla
    // necesita escuchar ThemeController por su cuenta.
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) => MaterialApp.router(
        title: 'CogniFit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeController.instance.mode,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
