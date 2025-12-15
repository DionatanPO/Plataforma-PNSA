import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/acesso_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/info_badge.dart';

class AccessManagementMobileList extends StatelessWidget {
  final List<Acesso> acessos;
  final Function(Acesso) onEditUser;
  final Function(Acesso) onResetPassword;
  final ThemeData theme;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;

  const AccessManagementMobileList({
    Key? key,
    required this.acessos,
    required this.onEditUser,
    required this.onResetPassword,
    required this.theme,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: acessos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final acesso = acessos[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AvatarWidget(nome: acesso.nome, theme: theme, size: 40),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              acesso.nome,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              acesso.funcao,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    StatusBadge(status: acesso.status, compact: true),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoBadge(Icons.email_outlined, acesso.email),
                    InfoBadge(Icons.badge_outlined, (acesso as dynamic).cpf ?? 'CPF N/D'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => onEditUser(acesso),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => onResetPassword(acesso),
                      icon: const Icon(Icons.lock_reset_outlined, size: 16),
                      label: const Text('Redefinir Senha'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}