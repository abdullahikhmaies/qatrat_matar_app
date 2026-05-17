import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ======================================================
/// AppTheme — مستخرج من نظام تصميم Stitch AI
/// Qatrat Matar Design System v2.0
/// namedColors from Stitch FIDELITY color variant
/// customColor: #1a4d8c — overridePrimary: #1a4d8c
/// ======================================================
class AppTheme {
  AppTheme._();

  // ── Core Brand Colors (from Stitch Design System) ──────────────
  static const Color primary         = Color(0xFF00366D); // primary (Stitch)
  static const Color primaryContainer= Color(0xFF1A4D8C); // primary_container
  static const Color onPrimary       = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF9ABFFF);
  static const Color inversePrimary  = Color(0xFFA8C8FF);

  static const Color secondary       = Color(0xFF006783); // secondary (Stitch)
  static const Color secondaryContainer = Color(0xFF6DD6FF);
  static const Color onSecondary     = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF005C75);

  static const Color tertiary        = Color(0xFF003C4F); // tertiary (Stitch)
  static const Color tertiaryContainer  = Color(0xFF00546E);
  static const Color onTertiary      = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF63CAF7);

  // ── Surface & Background ───────────────────────────────────────
  static const Color background      = Color(0xFFF8F9FF); // background (Stitch)
  static const Color onBackground    = Color(0xFF161C23);
  static const Color surface         = Color(0xFFF8F9FF);
  static const Color surfaceBright   = Color(0xFFF8F9FF);
  static const Color surfaceDim      = Color(0xFFD5DAE4);
  static const Color surfaceContainerLowest  = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow     = Color(0xFFEFF4FE);
  static const Color surfaceContainer        = Color(0xFFE9EEF8);
  static const Color surfaceContainerHigh    = Color(0xFFE3E8F2);
  static const Color surfaceContainerHighest = Color(0xFFDEE3ED);
  static const Color surfaceVariant  = Color(0xFFDEE3ED);
  static const Color surfaceTint     = Color(0xFF315F9F);
  static const Color inverseSurface  = Color(0xFF2B3138);
  static const Color inverseOnSurface= Color(0xFFECF1FB);

  // ── On Surface ─────────────────────────────────────────────────
  static const Color onSurface         = Color(0xFF161C23);
  static const Color onSurfaceVariant  = Color(0xFF424750);

  // ── Outline ────────────────────────────────────────────────────
  static const Color outline         = Color(0xFF737781);
  static const Color outlineVariant  = Color(0xFFC3C6D2);

  // ── Error ──────────────────────────────────────────────────────
  static const Color error           = Color(0xFFBA1A1A);
  static const Color errorContainer  = Color(0xFFFFDAD6);
  static const Color onError         = Color(0xFFFFFFFF);
  static const Color onErrorContainer= Color(0xFF93000A);

  // ── Fixed Colors ───────────────────────────────────────────────
  static const Color primaryFixed        = Color(0xFFD6E3FF);
  static const Color primaryFixedDim     = Color(0xFFA8C8FF);
  static const Color onPrimaryFixed      = Color(0xFF001B3C);
  static const Color onPrimaryFixedVariant = Color(0xFF0F4685);
  static const Color secondaryFixed      = Color(0xFFBCE9FF);
  static const Color secondaryFixedDim   = Color(0xFF68D3FD);
  static const Color onSecondaryFixed    = Color(0xFF001F29);
  static const Color onSecondaryFixedVariant = Color(0xFF004D63);
  static const Color tertiaryFixed       = Color(0xFFBFE9FF);
  static const Color tertiaryFixedDim    = Color(0xFF6DD2FF);
  static const Color onTertiaryFixed     = Color(0xFF001F2A);
  static const Color onTertiaryFixedVariant = Color(0xFF004D65);

  // ── Semantic Alias (used in code for convenience) ──────────────
  static const Color success         = Color(0xFF22C55E);
  static const Color warning         = Color(0xFFF59E0B);
  static const Color info            = Color(0xFF3BAED6); // sky blue water

  // ── Brand Specific (override primary) ──────────────────────────
  static const Color brandNavy       = Color(0xFF1A4D8C); // primaryContainer
  static const Color brandSkyBlue    = Color(0xFF3BAED6); // overrideSecondary
  static const Color brandLightBlue  = Color(0xFF6CD2FF); // overrideTertiary

  // ── Gradients ──────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A4D8C), Color(0xFF3BAED6)],
  );

  static const LinearGradient walletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A6B), Color(0xFF1A4D8C), Color(0xFF2E6BC4)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD6E3FF), Color(0xFFF8F9FF)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF00366D), Color(0xFF1A4D8C)],
  );

  // ── BoxShadow ──────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1A4D8C).withValues(alpha: 0.08),
      blurRadius: 30,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(0xFF1A4D8C).withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Typography (Tajawal — Arabic optimized) ────────────────────
  static TextTheme get _tajawalTextTheme => TextTheme(
    displayLarge:  GoogleFonts.tajawal(fontSize: 48, fontWeight: FontWeight.w700, height: 1.25),
    displayMedium: GoogleFonts.tajawal(fontSize: 36, fontWeight: FontWeight.w700, height: 1.22),
    displaySmall:  GoogleFonts.tajawal(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
    headlineLarge: GoogleFonts.tajawal(fontSize: 32, fontWeight: FontWeight.w700, height: 1.25),
    headlineMedium:GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.w500, height: 1.33),
    headlineSmall: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w500, height: 1.4),
    titleLarge:    GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w600, height: 1.44),
    titleMedium:   GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
    titleSmall:    GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43),
    bodyLarge:     GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w400, height: 1.56),
    bodyMedium:    GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
    bodySmall:     GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43),
    labelLarge:    GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43),
    labelMedium:   GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33),
    labelSmall:    GoogleFonts.tajawal(fontSize: 10, fontWeight: FontWeight.w500, height: 1.6),
  );

  // ── Main Light Theme ───────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      // Core
      primary:            Color(0xFF00366D),
      onPrimary:          Color(0xFFFFFFFF),
      primaryContainer:   Color(0xFF1A4D8C),
      onPrimaryContainer: Color(0xFF9ABFFF),
      // Secondary
      secondary:            Color(0xFF006783),
      onSecondary:          Color(0xFFFFFFFF),
      secondaryContainer:   Color(0xFF6DD6FF),
      onSecondaryContainer: Color(0xFF005C75),
      // Tertiary
      tertiary:            Color(0xFF003C4F),
      onTertiary:          Color(0xFFFFFFFF),
      tertiaryContainer:   Color(0xFF00546E),
      onTertiaryContainer: Color(0xFF63CAF7),
      // Error
      error:            Color(0xFFBA1A1A),
      onError:          Color(0xFFFFFFFF),
      errorContainer:   Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      // Surface & Background
      surface:          Color(0xFFF8F9FF),
      onSurface:        Color(0xFF161C23),
      surfaceContainerHighest: Color(0xFFDEE3ED),
      onSurfaceVariant: Color(0xFF424750),
      inverseSurface:   Color(0xFF2B3138),
      inversePrimary:   Color(0xFFA8C8FF),
      // Outline
      outline:        Color(0xFF737781),
      outlineVariant: Color(0xFFC3C6D2),
      // Scrim/shadow
      scrim:          Color(0xFF000000),
      shadow:         Color(0xFF000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: _tajawalTextTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.tajawal(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryContainer,
          side: const BorderSide(color: Color(0xFF1A4D8C), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC3C6D2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3BAED6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        hintStyle: GoogleFonts.tajawal(
          color: const Color(0xFF737781),
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFDEE3ED), width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerLow,
        labelStyle: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLowest,
        selectedItemColor: primaryContainer,
        unselectedItemColor: const Color(0xFF737781),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 11),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFDEE3ED),
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: inverseSurface,
        contentTextStyle: GoogleFonts.tajawal(color: inverseOnSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
