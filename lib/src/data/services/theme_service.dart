import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static const String _themeKey = 'selected_theme';
  final GetStorage _box = GetStorage();

  // Define o tema selecionado
  Future<void> setTheme(ThemeMode themeMode) async {
    await _box.write(_themeKey, themeMode.toString());
  }

  // Obtém o tema selecionado, ou o padrão se nenhum estiver definido
  ThemeMode getSelectedTheme() {
    final themeString = _box.read<String>(_themeKey);
    if (themeString != null) {
      return ThemeMode.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemeMode.system, // Valor padrão se o valor salvo for inválido
      );
    }
    return ThemeMode.system; // Valor padrão
  }
}