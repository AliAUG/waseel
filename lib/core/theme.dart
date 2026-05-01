import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF00B4A0);
  static const Color primaryTealDark = Color(0xFF009688);
  static const Color carRed = Color(0xFFE53935);

  /// Cards / list rows: avoids near-white panels in dark mode where [onSurface] is a light color.
  /// [ColorScheme.fromSeed] can yield very light `surfaceContainer*` tones; cap luminance so text stays readable.
  static Color contentPanelColor(ColorScheme scheme) {
    if (scheme.brightness == Brightness.dark) {
      final c = scheme.surfaceContainerLowest;
      if (c.computeLuminance() > 0.22) {
        return const Color(0xFF2C2C2C);
      }
      return c;
    }
    return scheme.surfaceContainerHigh;
  }

  /// Chips and nested insets on panels.
  static Color contentInsetColor(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark
          ? scheme.surfaceContainerLow
          : scheme.surfaceContainerHighest;

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final fontFamily = textTheme.bodyMedium?.fontFamily;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: primaryTeal,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
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

  /// Arabic UI: Cairo. English UI: Plus Jakarta Sans.
  static ThemeData lightTheme({required bool useArabic}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: primaryTeal,
      brightness: Brightness.light,
    );
    final textTheme = useArabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.plusJakartaSansTextTheme();
    return _buildTheme(colorScheme: colorScheme, textTheme: textTheme);
  }

  static ThemeData darkTheme({required bool useArabic}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      primary: primaryTeal,
      brightness: Brightness.dark,
    );
    final base = ThemeData(brightness: Brightness.dark);
    final textTheme = useArabic
        ? GoogleFonts.cairoTextTheme(base.textTheme)
        : GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    return _buildTheme(colorScheme: colorScheme, textTheme: textTheme);
  }
}
