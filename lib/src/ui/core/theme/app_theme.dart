import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores da Paróquia
  static const Color primaryColor = Color(0xFF4f84f0);
  static const Color secondaryColor = Color(0xFFc8a755);
  static const Color accentColor = Color(0xFFFFB300);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);

  // ==========================================================
  // CONFIGURAÇÃO DO TEMA CLARO
  // ==========================================================
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
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      // Definição do botão no tema claro
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((
            Set<MaterialState> states,
          ) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade400;
            }
            return primaryColor;
          }),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ==========================================================
  // CONFIGURAÇÃO DO TEMA ESCURO (CORRIGIDO)
  // ==========================================================
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        // Forçamos o primary aqui também para evitar tons pastéis em outros lugares
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        onPrimary: Colors.white, // Garante texto branco em botões primários
        surface: const Color(0xFF1E1E1E), // Fundo de cards/dialogs
        onSurface: Colors.white, // Texto sobre suface
        background: const Color(0xFF121212), // Fundo do app
        onBackground: Colors.white,
      ),

      // Tema de Ícones
      iconTheme: const IconThemeData(color: primaryColor),

      // Tema para TextButton (Cancelar)
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(primaryColor),
        ),
      ),

      // Tema para OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(primaryColor),
          side: MaterialStateProperty.all(
            const BorderSide(color: Colors.white30),
          ),
        ),
      ),

      // Tema para FloatingActionButton (para evitar cores escuras do container M3)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Tema para FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(primaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      // Ajuste de texto para modo escuro
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor, // Mantém o azul no AppBar
        foregroundColor: Colors.white,
      ),

      // AQUI ESTÁ A SOLUÇÃO: Repetimos o estilo do botão explicitamente
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((
            Set<MaterialState> states,
          ) {
            if (states.contains(MaterialState.disabled)) {
              // Um cinza mais escuro para botões desabilitados no modo escuro
              return Colors.grey.shade800;
            }
            // AQUI: Força a cor primária exata (Azul) mesmo no modo escuro
            return primaryColor;
          }),
          // Garante que o texto seja branco (para constraste com o azul)
          foregroundColor: MaterialStateProperty.all(Colors.white),

          // Opcional: Ajuste a cor do ícone se houver
          iconColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
    );
  }
}
