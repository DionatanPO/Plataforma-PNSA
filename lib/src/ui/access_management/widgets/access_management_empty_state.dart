import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccessManagementEmptyState extends StatelessWidget {
  final String? searchQuery;

  const AccessManagementEmptyState({Key? key, this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Determina se a mensagem é para busca vazia ou para total ausência de dados
    final isSearching = searchQuery != null && searchQuery!.isNotEmpty;
    final title = isSearching
        ? 'Nenhum usuário encontrado'
        : 'Nenhum usuário cadastrado';
    final subtitle = isSearching
        ? 'Nenhum usuário corresponde à sua pesquisa "$searchQuery". Tente usar palavras-chave diferentes.'
        : 'Não há usuários cadastrados no sistema. Comece adicionando um novo usuário usando o botão "Novo Usuário".';

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.people_alt_rounded,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}