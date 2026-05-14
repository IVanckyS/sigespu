import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextStyle displayFont({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.02,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing * fontSize,
      );

  static TextStyle monoFont({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  // Paleta oficial SIGESPU Lota (definida en CLAUDE.md y Design System)
  static const orange600 = Color(0xFFEA580C);
  static const orange700 = Color(0xFFC2410C);
  static const orange500 = Color(0xFFF97316);
  static const orange100 = Color(0xFFFFEDD5);
  static const orange50  = Color(0xFFFFF7ED);

  static const blue800   = Color(0xFF1E3A8A);
  static const blue900   = Color(0xFF1E293B);

  static const stone900  = Color(0xFF1C1917);
  static const stone800  = Color(0xFF292524);
  static const stone700  = Color(0xFF44403C);
  static const stone600  = Color(0xFF57534E);
  static const stone500  = Color(0xFF78716C);
  static const stone400  = Color(0xFFA8A29E);
  static const stone300  = Color(0xFFD6D3D1);
  static const stone200  = Color(0xFFE7E5E4);
  static const stone100  = Color(0xFFF5F5F4);
  static const stone50   = Color(0xFFFAFAF9);

  static const greenSuccess = Color(0xFF15803D);
  static const redDanger    = Color(0xFFB91C1C);
  static const amberWarning = Color(0xFFD97706);
  static const infoBlue     = Color(0xFF1D4ED8);

  // Colores específicos de tipos (Design System)
  static const tSede        = Color(0xFF16A34A);
  static const tRobo        = Color(0xFFDC2626);
  static const tVandalismo  = Color(0xFF7C3AED);
  static const tLuminaria   = Color(0xFFCA8A04);
  static const tCamara      = Color(0xFF6D28D9);
  static const tArbol       = Color(0xFF65A30D);
  static const tSinLuz      = Color(0xFF374151);
  static const tSocavon     = Color(0xFF92400E);
  static const tAgua        = Color(0xFF0284C7);
  static const tBasural     = Color(0xFF78350F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orange600,
        primary: orange600,
        secondary: blue800,
        surface: stone50,
        error: redDanger,
        onPrimary: Colors.white,
        onSurface: stone900,
      ),
      scaffoldBackgroundColor: stone50,
      fontFamily: 'Inter', // Requiere añadir la fuente en pubspec si fuera local
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: stone900,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: stone700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
