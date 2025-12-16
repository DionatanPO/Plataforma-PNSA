import 'package:flutter/material.dart';
import '../../core/widgets/modern_search_bar.dart';

/// Barra de busca para o gerenciamento de acessos.
/// Utiliza o componente ModernSearchBar com configurações específicas.
class AccessManagementSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const AccessManagementSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Buscar por nome, CPF ou e-mail...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernSearchBar(
      controller: controller,
      onChanged: onChanged,
      hintText: hintText,
      autoUpdate: true,
    );
  }
}
