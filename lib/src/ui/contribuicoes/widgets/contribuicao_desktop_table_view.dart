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
                    _HeaderCell(text: 'D. REGISTRO', flex: 2, theme: theme),
                    _HeaderCell(text: 'D. PAGAMENTO', flex: 2, theme: theme),
                    _HeaderCell(text: 'FIÉL', flex: 3, theme: theme),
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
            // DATA REGISTRO
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(d.dataRegistro),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(d.dataRegistro),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.6))),
        ),
        Expanded(
          child: Text(value,
              style:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  void _showDetailsDialog(
      BuildContext context, Contribuicao d, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes do Lançamento',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Fiel:', d.dizimistaNome, theme),
              const SizedBox(height: 8),
              _detailRow('D. Registro:',
                  DateFormat('dd/MM/yyyy HH:mm').format(d.dataRegistro), theme),
              const SizedBox(height: 8),
              _detailRow('D. Pagamento:',
                  DateFormat('dd/MM/yyyy').format(d.dataPagamento), theme),
              const SizedBox(height: 8),
              _detailRow('Método:', d.metodo, theme),
              if (d.observacao?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _detailRow('Observação:', d.observacao ?? '', theme),
              ],
              const Divider(height: 24),
              Text('Meses Referência:',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              if (d.competencias.isEmpty)
                Text('Nenhum mês específico registrado.',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: theme.hintColor))
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: d.competencias.map((comp) {
                        final dateStr = comp.dataPagamento != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(comp.dataPagamento!)
                            : '-';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(comp.mesReferencia,
                                  style: GoogleFonts.inter(fontSize: 13)),
                              Text('Pago em: $dateStr',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: theme.hintColor)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  Text(
                      NumberFormat.simpleCurrency(locale: 'pt_BR')
                          .format(d.valor),
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green)),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
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
