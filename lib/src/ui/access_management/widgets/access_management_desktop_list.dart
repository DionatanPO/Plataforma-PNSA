import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/acesso_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/table_header.dart';

class AccessManagementDesktopList extends StatelessWidget {
  final List<Acesso> acessos;
  final Function(Acesso) onEditUser;
  final ThemeData theme;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;

  const AccessManagementDesktopList({
    Key? key,
    required this.acessos,
    required this.onEditUser,
    required this.theme,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
  }) : super(key: key);

  Widget _actionButton(IconData icon, Color color, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      children: [
                        TableHeader(text: 'USUÁRIO', flex: 3),
                        TableHeader(text: 'CONTATO / CPF', flex: 2),
                        TableHeader(text: 'FUNÇÃO', flex: 2),
                        TableHeader(text: 'STATUS', flex: 1),
                        TableHeader(text: 'ÚLTIMO ACESSO', flex: 2),
                        TableHeader(text: 'AÇÕES', flex: 1, alignRight: true),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final acesso = acessos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  color: surfaceColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  AvatarWidget(nome: acesso.nome, theme: theme),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(acesso.nome, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                                        Text(acesso.email, style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((acesso as dynamic).cpf ?? '---', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                                  Text(acesso.telefone.isNotEmpty ? acesso.telefone : '---', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(acesso.funcao, style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(alignment: Alignment.centerLeft, child: StatusBadge(status: acesso.status)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(acesso.ultimoAcesso != null ? acesso.ultimoAcesso!.toString() : 'Nunca', style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _actionButton(Icons.edit_outlined, Colors.blue, () => onEditUser(acesso)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < acessos.length - 1)
                        const Divider(height: 1, indent: 24, endIndent: 24),
                    ],
                  ),
                ),
              );
            },
            childCount: acessos.length,
          ),
        ),
      ],
    );
  }
}