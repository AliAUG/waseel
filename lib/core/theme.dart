import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF00B4A0);
  static const Color primaryTealDark = Color(0xFF009688);
  static const Color carRed = Color(0xFFE53935);

  /// Arabic UI: Noto Sans Arabic. English UI: Inter.
  static ThemeData lightTheme({required bool useArabic}) {
    final textTheme = useArabic
        ? GoogleFonts.notoSansArabicTextTheme()
        : GoogleFonts.interTextTheme();
    final fontFamily = textTheme.bodyMedium?.fontFamily;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
