import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';

/// Bloquea capturas de pantalla y grabación (FLAG_SECURE) en toda la app,
/// ya que prácticamente cada pantalla expone datos clínicos de menores
/// (HU-FL-01, HU-FL-04; protección de menores ligada a HU-BD-11).
/// Solo tiene efecto en Android: iOS no expone una API equivalente para
/// bloquear capturas a nivel de sistema.
class ScreenSecurity {
  static Future<void> enable() => FlutterWindowManagerPlus.addFlags(
        FlutterWindowManagerPlus.FLAG_SECURE,
      );
}
