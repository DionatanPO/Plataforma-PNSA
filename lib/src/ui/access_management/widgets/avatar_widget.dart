import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarWidget extends StatelessWidget {
  final String nome;
  final ThemeData theme;
  final double size;

  const AvatarWidget({
    Key? key,
    required this.nome,
    required this.theme,
    this.size = 36,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          _getInitials(nome),
          style: GoogleFonts.outfit(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  String _getInitials(String nomeCompleto) {
    final nomes = nomeCompleto.split(' ');
    if (nomes.length >= 2) {
      final primeiraInicial = nomes.first.isNotEmpty ? nomes.first[0] : '';
      final ultimaInicial = nomes.last.isNotEmpty ? nomes.last[0] : '';
      return '$primeiraInicial$ultimaInicial'.toUpperCase();
    } else {
      return nomes.isNotEmpty && nomes.first.isNotEmpty ? '${nomes.first[0]}' : '';
    }
  }
}