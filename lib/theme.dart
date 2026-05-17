import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A4D8C);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF00B4D8);
  static const Color background = Color(0xFFF0F7FF);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF111C2C);
  static const Color onSurfaceVariant = Color(0xFF707784);
  static const Color primaryContainer = Color(0xFFE3F2FD);
  static const Color onPrimary = Colors.white;
  static const Color secondaryContainer = Color(0xFF6CD2FF);
  static const Color surfaceContainerHigh = Color(0xFFDEE8FF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: background,
      onSurface: onSurface,
    ),
    textTheme: GoogleFonts.manropeTextTheme().copyWith(
      headlineLarge: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: onSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05,
        color: onSurfaceVariant,
      ),
    ),
  );
}
