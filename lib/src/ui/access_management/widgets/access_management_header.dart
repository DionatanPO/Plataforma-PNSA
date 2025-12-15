import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccessManagementHeader extends StatelessWidget {
  final VoidCallback onAddUserPressed;

  const AccessManagementHeader({
    Key? key,
    required this.onAddUserPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return SliverAppBar(
      backgroundColor: surfaceColor.withOpacity(isDark ? 0.8 : 0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      toolbarHeight: 90,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gestão de Acesso',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Administre usuários e permissões do sistema',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAddUserPressed,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Novo Usuário'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}