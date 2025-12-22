import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../data/services/session_service.dart';
import '../models/dizimista_model.dart';
import '../controllers/dizimista_controller.dart';
import 'dizimista_avatar.dart';
import 'status_badge.dart';
import 'table_header_cell.dart';
import 'action_button.dart';

// Funções de formatação
String formatCPF(String cpf) {
  if (cpf.isEmpty) return '';
  // Remove qualquer caractere que não seja número
  final numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
  if (numbers.length != 11)
    return cpf; // Retorna original se não tiver 11 dígitos
  return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
}

String formatPhone(String phone) {
  if (phone.isEmpty) return '';
  // Remove qualquer caractere que não seja número
  final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (numbers.length == 11) {
    // Celular: (XX) XXXXX-XXXX
    return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
  } else if (numbers.length == 10) {
    // Fixo: (XX) XXXX-XXXX
    return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
  }
  return phone; // Retorna original se não tiver formato esperado
}

class DizimistaDesktopTableView extends StatelessWidget {
  final List<Dizimista> lista;
  final ThemeData theme;
  final Color surfaceColor;
  final Function(Dizimista) onEditPressed;
  final Function(Dizimista) onViewHistoryPressed;

  const DizimistaDesktopTableView({
    Key? key,
    required this.lista,
    required this.theme,
    required this.surfaceColor,
    required this.onEditPressed,
    required this.onViewHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    return Container(
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
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                _TableHeaderCell(text: 'Nº', flex: 1, theme: theme),
                _TableHeaderCell(text: 'FIÉL', flex: 3, theme: theme),
                _TableHeaderCell(text: 'CONTATO', flex: 2, theme: theme),
                _TableHeaderCell(text: 'LOCALIZAÇÃO', flex: 2, theme: theme),
                _TableHeaderCell(text: 'STATUS', flex: 1, theme: theme),
                _TableHeaderCell(
                    text: 'ÚLT. CONTRIBUIÇÃO', flex: 2, theme: theme),
                _TableHeaderCell(text: 'CADASTRO', flex: 1, theme: theme),
                _TableHeaderCell(text: '', flex: 1, theme: theme),
              ],
            ),
          ),

          // Linhas da tabela
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lista.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 24,
              endIndent: 24,
              color: borderColor,
            ),
            itemBuilder: (context, index) {
              final d = lista[index];
              return _TableRow(
                dizimista: d,
                theme: theme,
                borderColor: borderColor,
                onEditPressed: onEditPressed,
                onViewHistoryPressed: onViewHistoryPressed,
              );
            },
          ),
        ],
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
          color: theme.colorScheme.onSurface
              .withOpacity(theme.brightness == Brightness.dark ? 0.8 : 0.6),
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
  final Dizimista dizimista;
  final ThemeData theme;
  final Color borderColor;
  final Function(Dizimista) onEditPressed;
  final Function(Dizimista) onViewHistoryPressed;

  const _TableRow({
    required this.dizimista,
    required this.theme,
    required this.borderColor,
    required this.onEditPressed,
    required this.onViewHistoryPressed,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.dizimista;
    final theme = widget.theme;
    final isDark = theme.brightness == Brightness.dark;

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
            // Coluna 1: Número de Registro
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  d.numeroRegistro,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? theme.colorScheme.primary
                        : theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 2: Avatar + Nome
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  DizimistaAvatar(nome: d.nome, theme: theme),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.nome,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.08,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.badge_outlined,
                                size: 10,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatCPF(d.cpf),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
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

            // Coluna 3: Contato
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          formatPhone(d.telefone),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (d.email != null && d.email!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            d.email!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 4: Endereço
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${d.rua ?? ''}${d.numero != null && d.numero!.isNotEmpty ? ", ${d.numero}" : ""}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 19),
                    child: Text(
                      '${d.cidade} - ${d.estado}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 5: Status
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(status: d.status),
              ),
            ),

            const SizedBox(width: 12),

            // Coluna 6: Última Contribuição
            Expanded(
              flex: 2,
              child: Obx(() {
                final controller = Get.find<DizimistaController>();
                final timeAgo = controller.getTimeSinceLastContribution(d.id);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: timeAgo == 'Nenhuma'
                        ? Colors.orange.withOpacity(isDark ? 0.15 : 0.1)
                        : theme.colorScheme.primary
                            .withOpacity(isDark ? 0.15 : 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 13,
                        color: timeAgo == 'Nenhuma'
                            ? (isDark ? Colors.orangeAccent : Colors.orange)
                            : (isDark
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: timeAgo == 'Nenhuma'
                                ? (isDark
                                    ? Colors.orangeAccent
                                    : Colors.orange.shade800)
                                : (isDark
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(width: 12),

            // Coluna 7: Data Registro
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: theme.colorScheme.onSurface
                          .withOpacity(isDark ? 0.7 : 0.5),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${d.dataRegistro.day.toString().padLeft(2, '0')}/${d.dataRegistro.month.toString().padLeft(2, '0')}/${d.dataRegistro.year}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface
                              .withOpacity(isDark ? 0.9 : 0.6),
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

            // Coluna 7: Ações
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botão Histórico
                  Obx(() {
                    final sessionService = Get.find<SessionService>();
                    if (!sessionService.isSecretaria) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => widget.onViewHistoryPressed(d),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(
                                        theme.brightness == Brightness.dark
                                            ? 0.25
                                            : 0.15),
                                    theme.colorScheme.primary.withOpacity(
                                        theme.brightness == Brightness.dark
                                            ? 0.12
                                            : 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    );
                  }),
                  // Botão Editar
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onEditPressed(d),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.1),
                              theme.colorScheme.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
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
}
