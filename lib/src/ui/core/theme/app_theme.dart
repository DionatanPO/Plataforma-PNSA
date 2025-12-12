import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores da Paróquia Nossa Senhora Auxiliadora
  static const Color primaryColor = Color(0xFF4f84f0); // Verde escuro religioso
  static const Color secondaryColor = Color(0xFFc8a755); // Verde médio
  static const Color accentColor = Color(0xFFFFB300); // Dourado/Amarelo para destaque
  static const Color backgroundColor = Color(0xFFF5F5F5); // Fundo claro
  static const Color surfaceColor = Color(0xFFFFFFFF); // Superfície branca

  // Configuração do Tema Claro
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
      ),
      // Aplica a fonte Google globalmente
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        color: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(primaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
    );
  }

  // Configuração do Tema Escuro
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        color: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(primaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
    );
  }
}