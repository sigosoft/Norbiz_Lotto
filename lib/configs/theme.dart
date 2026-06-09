import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryOrange = Color(0xFFF58220);
  static const Color primaryDarkBlue = Color(0xFF0D47A1);
  static const Color secondaryDarkBlue = Color(0xFF1565C0);
  static const Color lightGreyBg = Color(0xFFF4F6F9);

  // Login / Auth Screen Colors
  static const Color loginSheetBlue = Color(0xFF002C8B);
  static const Color buttonOrange = Color(0xFFFE9900);

  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFF757575);

  // Game Card Gradients
  static const Gradient borletteGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFF58220)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient lotto3Gradient = LinearGradient(
    colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient lotto4Gradient = LinearGradient(
    colors: [Color(0xFFEC407A), Color(0xFFC2185B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardBlueGradient = LinearGradient(
    colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Login bottom sheet gradient: white at top → #002C8B at bottom
  static const Gradient loginSheetGradient = LinearGradient(
    colors: [Color.fromARGB(255, 186, 213, 249), loginSheetBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        secondary: primaryDarkBlue,
        background: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, color: textDark),
        bodyMedium: GoogleFonts.outfit(fontSize: 14, color: textGrey),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF4F6F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
