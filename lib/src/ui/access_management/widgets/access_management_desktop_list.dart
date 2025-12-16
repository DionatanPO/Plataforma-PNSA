import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/acesso_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/table_header.dart';

class AccessManagementDesktopList extends StatelessWidget {
  final List<Acesso> acessos;
  final Function(Acesso) onEditUser;
  final Function(Acesso) onResetPassword;
  final ThemeData theme;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;

  const AccessManagementDesktopList({
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Cabeçalho da tabela
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withOpacity(0.05),
                      theme.primaryColor.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(color: borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    _TableHeaderCell(text: 'USUÁRIO', flex: 3, theme: theme),
                    _TableHeaderCell(text: 'CONTATO', flex: 2, theme: theme),
                    _TableHeaderCell(text: 'FUNÇÃO', flex: 2, theme: theme),
                    _TableHeaderCell(text: 'STATUS', flex: 1, theme: theme),
                    _TableHeaderCell(text: 'ÚLTIMO ACESSO', flex: 2, theme: theme),
                    _TableHeaderCell(text: '', flex: 1, theme: theme),
                  ],
                ),
              ),

              // Linhas da tabela
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: acessos.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 24,
                  endIndent: 24,
                  color: borderColor,
                ),
                itemBuilder: (context, index) {
                  final acesso = acessos[index];
                  return _TableRow(
                    acesso: acesso,
                    theme: theme,
                    borderColor: borderColor,
                    onEditUser: onEditUser,
                    onResetPassword: onResetPassword,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// COMPONENTE: HEADER CELL
// =============================================================================
class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final ThemeData theme;

  const _TableHeaderCell({
    required this.text,
    required this.flex,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// =============================================================================
// COMPONENTE: TABLE ROW COM HOVER
// =============================================================================
class _TableRow extends StatefulWidget {
  final Acesso acesso;
  final ThemeData theme;
  final Color borderColor;
  final Function(Acesso) onEditUser;
  final Function(Acesso) onResetPassword;

  const _TableRow({
    required this.acesso,
    required this.theme,
    required this.borderColor,
    required this.onEditUser,
    required this.onResetPassword,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovering = false;

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Nunca';

    try {
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Hoje às ${DateFormat('HH:mm').format(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Ontem às ${DateFormat('HH:mm').format(dateTime)}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} dias atrás';
      } else {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } catch (e) {
      return 'Nunca';
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.acesso;
    final theme = widget.theme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _isHovering
              ? theme.colorScheme.onSurface.withOpacity(0.02)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Coluna 1: Avatar + Nome + Email
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  AvatarWidget(nome: a.nome, theme: theme),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                a.nome,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (a.pendencia) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning_rounded,
                                      size: 10,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pendente',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 11,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                a.email,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 2: CPF + Telefone
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (a as dynamic).cpf ?? '---',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        a.telefone.isNotEmpty ? a.telefone : '---',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 3: Função
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getFuncaoColor(a.funcao).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getFuncaoColor(a.funcao).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFuncaoIcon(a.funcao),
                      size: 14,
                      color: _getFuncaoColor(a.funcao),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        a.funcao,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getFuncaoColor(a.funcao),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 4: Status
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(status: a.status),
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 5: Último Acesso
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _formatDateTime(a.ultimoAcesso),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 6: Ações
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onEditUser(a),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.15),
                              Colors.blue.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onResetPassword(a),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(0.15),
                              Colors.orange.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFuncaoColor(String funcao) {
    switch (funcao.toLowerCase()) {
      case 'administrador':
        return Colors.purple;
      case 'secretário':
      case 'secretario':
        return Colors.blue;
      case 'tesoureiro':
        return Colors.green;
      case 'coordenador':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getFuncaoIcon(String funcao) {
    switch (funcao.toLowerCase()) {
      case 'administrador':
        return Icons.admin_panel_settings_rounded;
      case 'secretário':
      case 'secretario':
        return Icons.edit_note_rounded;
      case 'tesoureiro':
        return Icons.account_balance_wallet_rounded;
      case 'coordenador':
        return Icons.people_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}