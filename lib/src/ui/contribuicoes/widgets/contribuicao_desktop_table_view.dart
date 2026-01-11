import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/contribuicao_model.dart';
import '../controllers/contribuicao_controller.dart';

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
                    _HeaderCell(text: 'DATA', flex: 2, theme: theme),
                    _HeaderCell(text: 'FIÉL', flex: 4, theme: theme),
                    _HeaderCell(text: 'TIPO', flex: 2, theme: theme),
                    _HeaderCell(text: 'MÉTODO', flex: 2, theme: theme),
                    _HeaderCell(text: 'VALOR', flex: 2, theme: theme),
                    _HeaderCell(text: 'AÇÕES', flex: 1, theme: theme),
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
  final VoidCallback onReceiptPressed;
  final bool isLast;

  const _ContribuicaoTableRow({
    Key? key,
    required this.item,
    required this.theme,
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
            // DATA
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
            // FIÉL
            Expanded(
              flex: 4,
              child: Text(
                d.dizimistaNome,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            // TIPO
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  d.tipo,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
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
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.receipt_long_rounded, size: 20),
                    onPressed: widget.onReceiptPressed,
                    color: theme.primaryColor,
                    tooltip: 'Ver Recibo',
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
