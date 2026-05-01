import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';

/// Locale-aware body font: [Noto Sans Arabic] when UI is Arabic, [Inter] when English.
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
        ? GoogleFonts.notoSansArabic(textStyle: base)
        : GoogleFonts.inter(textStyle: base);
  }
}
