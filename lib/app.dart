import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class CogniFitApp extends ConsumerWidget {
  const CogniFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // El router sale de un provider (ver core/router/app_router.dart) en vez
    // de un `static final` suelto, para que en el futuro pueda leer otros
    // providers (p. ej. redirigir a /login si la sesión expiró).
    final router = ref.watch(goRouterProvider);

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
        routerConfig: router,
      ),
    );
  }
}
