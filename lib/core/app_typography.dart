import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

/// Locale-aware body font: [Cairo] when UI is Arabic, [Plus Jakarta Sans] when English.
extension AppTypographyX on BuildContext {
  TextStyle appFont({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final useArabic =
        watch<SettingsProvider>().language == AppLanguage.arabic;
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
    return useArabic
        ? GoogleFonts.cairo(textStyle: base)
        : GoogleFonts.plusJakartaSans(textStyle: base);
  }
}
