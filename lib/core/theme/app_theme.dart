import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF7C5CBF);
  static const Color primaryContainer = Color(0xFFEDE7F6);
  static const Color secondary = Color(0xFF9C7DE0);
  static const Color tertiary = Color(0xFF5BC8AF);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFA726);
  static const Color surface = Color(0xFFF5F3F8);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color outline = Color(0xFFE0D9ED);
  static const Color riskRed = Color(0xFFFF6B6B);
  static const Color activeGreen = Color(0xFF4CAF84);
  static const Color pendingOrange = Color(0xFFFFB74D);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFF21005D),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEADDFF),
      onSecondaryContainer: Color(0xFF21005D),
      tertiary: tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD7F5EC),
      onTertiaryContainer: Color(0xFF00382A),
      error: error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: Color(0xFFEDE7F6),
      onSurfaceVariant: Color(0xFF49454F),
      outline: outline,
      outlineVariant: Color(0xFFCAC4D0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFCFBCFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayMedium: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: onSurface),
        headlineLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: onSurface),
        headlineMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
        titleLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
        titleMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: onSurface),
        bodyMedium: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF49454F)),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
        labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF49454F)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: outline, width: 1.5),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: error)),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Color(0xFFADA9B9)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outline.withOpacity(0.6)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
        iconTheme: const IconThemeData(color: onSurface),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFFADA9B9),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      ),
    );
  }
}
