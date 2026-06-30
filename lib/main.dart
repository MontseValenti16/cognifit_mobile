import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/security/screen_security.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenSecurity.enable();
  await ConnectivityService.instance.initialize();
  runApp(const CogniFitApp());
}

class CogniFitApp extends StatelessWidget {
  const CogniFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CogniFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
