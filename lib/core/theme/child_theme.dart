import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema tipográfico exclusivo de las pantallas donde el alumno responde
/// directamente (features/exercise y features/intervention): interlineado,
/// espaciado de letras y palabras pensados para dislexia, y Open Sans en vez
/// de Poppins.
///
/// Nunca redefine el tema: siempre parte de `base` (el ThemeData vigente,
/// claro u oscuro, tal como lo arma AppTheme) con copyWith, así que los
/// colores y el modo claro/oscuro los sigue decidiendo AppTheme — este
/// archivo no toca ni conoce colores.
ThemeData childTheme(ThemeData base) {
  // GoogleFonts.xTextTheme(base) conserva tamaño, peso y color de cada
  // estilo del tema recibido y solo cambia la familia tipográfica: así se
  // respetan los colores dinámicos (AppTheme.onSurface, AppTheme.mutedText,
  // etc., ya resueltos dentro de `base`) sin tener que repetirlos aquí.
  final openSans = GoogleFonts.openSansTextTheme(base.textTheme);

  final textTheme = openSans.copyWith(
    bodyMedium: openSans.bodyMedium?.copyWith(letterSpacing: 0.3, height: 1.7, wordSpacing: 2.0),
    bodyLarge: openSans.bodyLarge?.copyWith(letterSpacing: 0.3, height: 1.7, wordSpacing: 2.0),
    titleMedium: openSans.titleMedium?.copyWith(letterSpacing: 0.3),
  );

  return base.copyWith(
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: _childButtonStyle(base.elevatedButtonTheme.style)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _childButtonStyle(base.outlinedButtonTheme.style)),
    textButtonTheme: TextButtonThemeData(style: _childButtonStyle(base.textButtonTheme.style)),
  );
}

/// Botones y opciones en Open Sans, con al menos 16px de letra y un tap
/// target de al menos 48x48 — sin tocar color ni el ancho/alto que ya trae
/// cada botón (los de AppTheme ya son de ancho completo y 52px de alto, más
/// que suficiente; esto solo sube el mínimo si algún estilo llegara más
/// chico, nunca lo agranda de más).
ButtonStyle? _childButtonStyle(ButtonStyle? style) {
  if (style == null) return null;
  final currentTextStyle = style.textStyle?.resolve(const {});
  final openSansStyle = GoogleFonts.openSans(textStyle: currentTextStyle);
  final fontSize = openSansStyle.fontSize ?? 16;

  final currentMinSize = style.minimumSize?.resolve(const {}) ?? const Size(48, 48);
  final minSize = Size(
    currentMinSize.width == double.infinity ? currentMinSize.width : (currentMinSize.width < 48 ? 48 : currentMinSize.width),
    currentMinSize.height < 48 ? 48 : currentMinSize.height,
  );

  return style.copyWith(
    textStyle: WidgetStatePropertyAll(openSansStyle.copyWith(fontSize: fontSize < 16 ? 16 : fontSize)),
    minimumSize: WidgetStatePropertyAll(minSize),
  );
}
