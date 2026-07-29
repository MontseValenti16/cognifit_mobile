import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData childTheme(ThemeData base) {
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
