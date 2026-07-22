import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla el modo claro/oscuro de toda la app. Es un singleton global (no
/// pasa por ServiceLocator/sesión) porque MaterialApp lo necesita ANTES de
/// que exista cualquier pantalla, y debe sobrevivir al login/logout.
///
/// Deliberadamente binario (solo light/dark, nunca ThemeMode.system): el
/// pedido es un botón sol/luna con dos estados, no un tercer modo automático.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'cognifit_theme_mode';

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  /// Carga la preferencia guardada. Se llama una vez en main() antes de
  /// runApp — si no hay nada guardado, se queda en claro (default).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == 'dark') _mode = ThemeMode.dark;
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, isDark ? 'dark' : 'light');
  }
}
