import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_controller.dart';

class _Palette {
  final Color primary, primaryContainer, secondary, tertiary, error, warning;
  final Color surface, onSurface, outline, mutedText, cardColor;
  final Color riskRed, activeGreen, pendingOrange;
  const _Palette({
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.tertiary,
    required this.error,
    required this.warning,
    required this.surface,
    required this.onSurface,
    required this.outline,
    required this.mutedText,
    required this.cardColor,
    required this.riskRed,
    required this.activeGreen,
    required this.pendingOrange,
  });
}

const _lightPalette = _Palette(
  primary: Color(0xFF7C5CBF),
  primaryContainer: Color(0xFFEDE7F6),
  secondary: Color(0xFF9C7DE0),
  tertiary: Color(0xFF5BC8AF),
  error: Color(0xFFE57373),
  warning: Color(0xFFFFA726),
  surface: Color(0xFFF5F3F8),
  onSurface: Color(0xFF1C1B1F),
  outline: Color(0xFFE0D9ED),
  mutedText: Color(0xFF6B6880),
  cardColor: Colors.white,
  riskRed: Color(0xFFFF6B6B),
  activeGreen: Color(0xFF4CAF84),
  pendingOrange: Color(0xFFFFB74D),
);

const _darkPalette = _Palette(
  primary: Color(0xFF9C86D6),
  primaryContainer: Color(0xFF352B54),
  secondary: Color(0xFFB39DDB),
  tertiary: Color(0xFF6FDDC4),
  error: Color(0xFFEF9A9A),
  warning: Color(0xFFFFB74D),
  surface: Color(0xFF15121F),
  onSurface: Color(0xFFECE6F5),
  outline: Color(0xFF3E3654),
  mutedText: Color(0xFFB0A9C4),
  cardColor: Color(0xFF1E1930),
  riskRed: Color(0xFFFF8A8A),
  activeGreen: Color(0xFF6FCE9E),
  pendingOrange: Color(0xFFFFC77D),
);

/// Colores de la app. Hasta ahora eran `static const Color`, usados
/// directamente como literales en cada pantalla (no vía `Theme.of(context)`).
/// Para que el modo oscuro se refleje en TODA la app sin reescribir cada uno
/// de esos cientos de call sites a `AppTheme.of(context).x`, siguen
/// llamándose igual (`AppTheme.primary`, `AppTheme.riskRed`, ...) pero ahora
/// son getters que resuelven según ThemeController.instance.isDark.
///
/// Costo de esta decisión: un getter no es una constante de compilación, así
/// que cualquier `const Widget(color: AppTheme.primary)` que existiera dejó
/// de compilar como `const` y hubo que quitarle esa palabra clave.
class AppTheme {
  static _Palette get _p => ThemeController.instance.isDark ? _darkPalette : _lightPalette;

  static Color get primary => _p.primary;
  static Color get primaryContainer => _p.primaryContainer;
  static Color get secondary => _p.secondary;
  static Color get tertiary => _p.tertiary;
  static Color get error => _p.error;
  static Color get warning => _p.warning;
  static Color get surface => _p.surface;
  static Color get onSurface => _p.onSurface;
  static Color get outline => _p.outline;
  static Color get riskRed => _p.riskRed;
  static Color get activeGreen => _p.activeGreen;
  static Color get pendingOrange => _p.pendingOrange;

  /// Superficie de tarjetas/inputs. Antes muchos widgets hardcodeaban
  /// Colors.white directamente porque no había una constante para esto — un
  /// blanco fijo sería ilegible en modo oscuro, así que se agrega ahora.
  static Color get cardColor => _p.cardColor;
  static Color get mutedText => _p.mutedText;

  static ThemeData get lightTheme => _buildTheme(_lightPalette, Brightness.light);
  static ThemeData get darkTheme => _buildTheme(_darkPalette, Brightness.dark);

  static ThemeData _buildTheme(_Palette p, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: Colors.white,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: dark ? p.onSurface : const Color(0xFF21005D),
      secondary: p.secondary,
      onSecondary: Colors.white,
      secondaryContainer: dark ? const Color(0xFF3D3465) : const Color(0xFFEADDFF),
      onSecondaryContainer: dark ? p.onSurface : const Color(0xFF21005D),
      tertiary: p.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: dark ? const Color(0xFF16453C) : const Color(0xFFD7F5EC),
      onTertiaryContainer: dark ? p.onSurface : const Color(0xFF00382A),
      error: p.error,
      onError: Colors.white,
      errorContainer: dark ? const Color(0xFF5A2A28) : const Color(0xFFFFDAD6),
      onErrorContainer: dark ? p.onSurface : const Color(0xFF410002),
      surface: p.surface,
      onSurface: p.onSurface,
      surfaceContainerHighest: dark ? const Color(0xFF241E38) : const Color(0xFFEDE7F6),
      onSurfaceVariant: p.mutedText,
      outline: p.outline,
      outlineVariant: dark ? const Color(0xFF2C2640) : const Color(0xFFCAC4D0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: dark ? const Color(0xFFECE6F5) : const Color(0xFF313033),
      onInverseSurface: dark ? const Color(0xFF15121F) : const Color(0xFFF4EFF4),
      inversePrimary: dark ? const Color(0xFF7C5CBF) : const Color(0xFFCFBCFF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.surface,
      textTheme: GoogleFonts.poppinsTextTheme(dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme).copyWith(
        displayMedium: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: p.onSurface),
        headlineLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: p.onSurface),
        headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: p.onSurface),
        titleLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: p.onSurface),
        titleMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: p.onSurface),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: p.onSurface),
        bodyMedium: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: p.mutedText),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
        labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: p.mutedText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: p.outline, width: 1.5),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.error)),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: p.mutedText),
      ),
      cardTheme: CardThemeData(
        color: p.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.outline.withValues(alpha: dark ? 0.8 : 0.6)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: p.onSurface),
        iconTheme: IconThemeData(color: p.onSurface),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.cardColor,
        selectedItemColor: p.primary,
        unselectedItemColor: p.mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      ),
    );
  }
}
