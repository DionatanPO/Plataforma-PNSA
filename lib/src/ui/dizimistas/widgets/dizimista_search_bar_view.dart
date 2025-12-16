import 'package:flutter/material.dart';
import '../../core/widgets/modern_search_bar.dart';

/// Barra de busca para dizimistas.
/// Utiliza o componente ModernSearchBar com configurações específicas.
class DizimistaSearchBarView extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const DizimistaSearchBarView({
    Key? key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Buscar por nome, CPF, telefone ou endereço...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernSearchBar(
      controller: controller,
      onChanged: onChanged ?? (_) {},
      hintText: hintText,
      autoUpdate: true,
    );
  }
}
