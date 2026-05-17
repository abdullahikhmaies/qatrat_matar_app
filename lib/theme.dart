import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ألوان العلامة التجارية - مستخرجة من اللوغو الرسمي
  static const Color primary = Color(0xFF1A4D8C);       // الأزرق الداكن الرئيسي
  static const Color primaryLight = Color(0xFF2E6BC4);  // الأزرق المتوسط
  static const Color secondary = Color(0xFF3BAED6);     // الأزرق السماوي
  static const Color accent = Color(0xFF6CD2FF);        // الأزرق الفاتح
  static const Color background = Color(0xFFF0F5FF);   // خلفية فاتحة مزرقة
  static const Color surfaceCard = Colors.white;
  static const Color onSurface = Color(0xFF111C2C);
  static const Color onSurfaceVariant = Color(0xFF707784);
  static const Color primaryContainer = Color(0xFFE3F0FF);
  static const Color onPrimary = Colors.white;
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // التدرج اللوني للأزرار الرئيسية
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A4D8C), Color(0xFF3BAED6)],
  );

  // التدرج للبطاقة المميزة (Wallet)
  static const LinearGradient walletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A6B), Color(0xFF1A4D8C), Color(0xFF2E6BC4)],
  );

  // التدرج للخلفية العلوية
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD6E8FF), Color(0xFFF0F5FF)],
    stops: [0.0, 0.35],
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: background,
      onSurface: onSurface,
    ),
    fontFamily: GoogleFonts.tajawal().fontFamily,
    textTheme: GoogleFonts.tajawalTextTheme().copyWith(
      displayLarge: GoogleFonts.tajawal(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: primary,
      ),
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineSmall: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: onSurface,
      ),
      labelSmall: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05,
        color: onSurfaceVariant,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      iconTheme: const IconThemeData(color: primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: error),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
    ),
  );
}
