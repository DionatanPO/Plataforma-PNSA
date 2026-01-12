import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/contribuicao_model.dart';
import '../controllers/contribuicao_controller.dart';
import '../../../data/services/session_service.dart';
import 'package:get/get.dart';

class ContribuicaoDesktopTableView extends StatelessWidget {
  final List<Contribuicao> items;
  final ThemeData theme;
  final ContribuicaoController controller;
  final Function(Contribuicao) onReceiptPressed;

  const ContribuicaoDesktopTableView({
    Key? key,
    required this.items,
    required this.theme,
    required this.controller,
    required this.onReceiptPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              // HEADER
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    _HeaderCell(text: 'D. PAGAMENTO', flex: 2, theme: theme),
                    _HeaderCell(text: 'FIÉL', flex: 3, theme: theme),
                    _HeaderCell(text: 'MÊS REF.', flex: 2, theme: theme),
                    _HeaderCell(text: 'MÉTODO', flex: 2, theme: theme),
                    _HeaderCell(text: 'STATUS', flex: 2, theme: theme),
                    _HeaderCell(text: 'VALOR', flex: 2, theme: theme),
                    _HeaderCell(text: 'AÇÕES', flex: 2, theme: theme),
                  ],
                ),
              );
            }

            final itemIndex = index - 1;
            final item = items[itemIndex];
            final isLast = itemIndex == items.length - 1;

            return Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  left: BorderSide(color: borderColor),
                  right: BorderSide(color: borderColor),
                  bottom:
                      isLast ? BorderSide(color: borderColor) : BorderSide.none,
                ),
                borderRadius: isLast
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )
                    : BorderRadius.zero,
              ),
              child: _ContribuicaoTableRow(
                item: item,
                theme: theme,
                controller: controller,
                onReceiptPressed: () => onReceiptPressed(item),
                isLast: isLast,
              ),
            );
          },
          childCount: items.length + 1,
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final ThemeData theme;

  const _HeaderCell(
      {required this.text, required this.flex, required this.theme});

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

class _ContribuicaoTableRow extends StatefulWidget {
  final Contribuicao item;
  final ThemeData theme;
  final ContribuicaoController controller;
  final VoidCallback onReceiptPressed;
  final bool isLast;

  const _ContribuicaoTableRow({
    Key? key,
    required this.item,
    required this.theme,
    required this.controller,
    required this.onReceiptPressed,
    required this.isLast,
  }) : super(key: key);

  @override
  State<_ContribuicaoTableRow> createState() => _ContribuicaoTableRowState();
}

class _ContribuicaoTableRowState extends State<_ContribuicaoTableRow> {
  bool _isHovering = false;

  String _formatMeses(List<String> meses) {
    if (meses.isEmpty) return '-';
    // Pega o primeiro e formata
    final first = meses.first;
    try {
      final parts = first.split('-');
      if (parts.length == 2) {
        final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        final formatted = DateFormat('MMM/yy', 'pt_BR').format(date);
        return meses.length > 1
            ? '${formatted[0].toUpperCase()}${formatted.substring(1)} (+${meses.length - 1})'
            : '${formatted[0].toUpperCase()}${formatted.substring(1)}';
      }
    } catch (_) {}
    return first;
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.item;
    final theme = widget.theme;
    final isDark = theme.brightness == Brightness.dark;
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovering
              ? theme.primaryColor.withOpacity(isDark ? 0.05 : 0.02)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(widget.isLast ? 0 : 0.05),
            ),
          ),
        ),
        child: Row(
          children: [
            // DATA PAGAMENTO
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(d.dataPagamento),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // FIÉL
            Expanded(
              flex: 3,
              child: Text(
                d.dizimistaNome,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            // MÊS REF
            Expanded(
              flex: 2,
              child: Text(
                _formatMeses(d.mesesCompetencia),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
            // MÉTODO
            Expanded(
              flex: 2,
              child: Text(
                d.metodo,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            // STATUS
            Expanded(
              flex: 2,
              child: _StatusBadge(status: d.status),
            ),
            // VALOR
            Expanded(
              flex: 2,
              child: Text(
                currency.format(d.valor),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            // AÇÕES
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, size: 20),
                    onPressed: () => _showDetailsDialog(context, d, theme),
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    tooltip: 'Ver Detalhes',
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.receipt_long_rounded, size: 20),
                    onPressed: widget.onReceiptPressed,
                    color: theme.primaryColor,
                    tooltip: 'Ver Recibo',
                  ),
                  if (Get.find<SessionService>().isFinanceiro) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () => _confirmDelete(context, d),
                      color: Colors.red.withOpacity(0.7),
                      tooltip: 'Apagar Lançamento',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Contribuicao d) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Deseja realmente apagar o lançamento de dízimo de ${d.dizimistaNome} no valor de ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(d.valor)}?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.controller.deleteContribuicao(d.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(
      BuildContext context, Contribuicao d, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.05),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long_rounded,
                          color: theme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Detalhes do Lançamento',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              )),
                          Text('ID: ${d.id.substring(0, 8).toUpperCase()}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              )),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Dados do Fiel', theme: theme),
                      const SizedBox(height: 12),
                      _ModernInfoRow(
                        icon: Icons.person_rounded,
                        label: 'Nome Completo',
                        value: d.dizimistaNome,
                        theme: theme,
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'Dados do Pagamento', theme: theme),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ModernInfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Data Pagamento',
                              value: DateFormat('dd/MM/yyyy')
                                  .format(d.dataPagamento),
                              theme: theme,
                              valueColor: theme.primaryColor,
                            ),
                          ),
                          Expanded(
                            child: _ModernInfoRow(
                              icon: Icons.payments_rounded,
                              label: 'Método',
                              value: d.metodo,
                              theme: theme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ModernInfoRow(
                        icon: Icons.history_rounded,
                        label: 'Data do Registro',
                        value: DateFormat('dd/MM/yyyy HH:mm')
                            .format(d.dataRegistro),
                        theme: theme,
                      ),
                      if (d.observacao?.isNotEmpty == true) ...[
                        const SizedBox(height: 24),
                        _SectionHeader(title: 'Observações', theme: theme),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.05)),
                          ),
                          child: Text(
                            d.observacao!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _SectionHeader(
                          title: 'Meses de Referência', theme: theme),
                      const SizedBox(height: 12),
                      if (d.competencias.isEmpty)
                        Text('Nenhum mês específico registrado.',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: theme.hintColor))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: d.competencias.map((comp) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 14, color: Colors.green),
                                  const SizedBox(width: 6),
                                  Text(
                                    comp.mesReferencia,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.02),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(28)),
                  border: Border(
                      top: BorderSide(
                          color: theme.dividerColor.withOpacity(0.1))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Valor Total',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5))),
                        Text(currency.format(d.valor),
                            style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ],
                    ),
                    if (Get.find<SessionService>().isFinanceiro) ...[
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.controller.toggleStatus(d);
                        },
                        icon: Icon(
                          d.status == 'Pago'
                              ? Icons.pending_rounded
                              : Icons.check_circle_rounded,
                          size: 18,
                          color:
                              d.status == 'Pago' ? Colors.orange : Colors.green,
                        ),
                        label: Text(
                          d.status == 'Pago'
                              ? 'Marcar como A Receber'
                              : 'Marcar como Pago',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: d.status == 'Pago'
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          backgroundColor: (d.status == 'Pago'
                                  ? Colors.orange
                                  : Colors.green)
                              .withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: theme.primaryColor,
      ),
    );
  }
}

class _ModernInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  const _ModernInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 18, color: theme.colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.5))),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? theme.colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPago = status == 'Pago';
    final color = isPago ? Colors.green : Colors.orange;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isPago ? Icons.check_circle_rounded : Icons.pending_rounded,
                  size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
