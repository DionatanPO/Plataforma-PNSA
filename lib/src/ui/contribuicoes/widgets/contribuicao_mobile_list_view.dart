import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/contribuicao_model.dart';
import '../controllers/contribuicao_controller.dart';
import '../../../data/services/session_service.dart';
import 'package:get/get.dart';

class ContribuicaoMobileListView extends StatelessWidget {
  final List<Contribuicao> items;
  final ThemeData theme;
  final Color surfaceColor;
  final ContribuicaoController controller;
  final Function(Contribuicao) onReceiptPressed;

  const ContribuicaoMobileListView({
    Key? key,
    required this.items,
    required this.theme,
    required this.controller,
    required this.surfaceColor,
    required this.onReceiptPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return ContribuicaoMobileListViewItem(
            key: ValueKey(item.id),
            item: item,
            theme: theme,
            surfaceColor: surfaceColor,
            controller: controller,
            onReceiptPressed: () => onReceiptPressed(item),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

class ContribuicaoMobileListViewItem extends StatelessWidget {
  final Contribuicao item;
  final ThemeData theme;
  final Color surfaceColor;
  final ContribuicaoController controller;
  final VoidCallback onReceiptPressed;

  const ContribuicaoMobileListViewItem({
    Key? key,
    required this.item,
    required this.theme,
    required this.surfaceColor,
    required this.controller,
    required this.onReceiptPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = item;
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(d.dataRegistro);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.dizimistaNome,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pago em: ${DateFormat('dd/MM/yyyy').format(d.dataPagamento)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Registrado: $dateStr',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Atendente: ${controller.getUsuarioNome(d.usuarioId)}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: d.status),
                  ],
                ),
              ),
              Text(
                currency.format(d.valor),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 8),
                  Text(
                    d.metodo,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 20),
                onPressed: () => _showDetailsDialog(context, d, theme),
                style: IconButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.05),
                  foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onReceiptPressed,
                icon: const Icon(Icons.receipt_long_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  foregroundColor: theme.primaryColor,
                ),
              ),
              if (Get.find<SessionService>().isFinanceiro) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(context, d),
                  icon: const Icon(Icons.delete_outline_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ],
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
              controller.deleteContribuicao(d.id);
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.05),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long_rounded,
                          color: theme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Detalhes',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          )),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Fiel', theme: theme),
                      const SizedBox(height: 8),
                      Text(d.dizimistaNome,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 20),
                      _SectionHeader(title: 'Pagamento', theme: theme),
                      const SizedBox(height: 12),
                      _ModernInfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Data Pagamento',
                        value: DateFormat('dd/MM/yyyy').format(d.dataPagamento),
                        theme: theme,
                        valueColor: theme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      _ModernInfoRow(
                        icon: Icons.payments_rounded,
                        label: 'Método',
                        value: d.metodo,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _ModernInfoRow(
                        icon: Icons.history_rounded,
                        label: 'Registro',
                        value:
                            DateFormat('dd/MM/yy HH:mm').format(d.dataRegistro),
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _ModernInfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Atendente',
                        value: controller.getUsuarioNome(d.usuarioId),
                        theme: theme,
                      ),
                      if (d.observacao?.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        _SectionHeader(title: 'Observações', theme: theme),
                        const SizedBox(height: 8),
                        Text(
                          d.observacao!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _SectionHeader(title: 'Meses Referência', theme: theme),
                      const SizedBox(height: 8),
                      if (d.competencias.isEmpty)
                        Text('Nenhum mês registrado.',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: theme.hintColor))
                      else
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: d.competencias.map((comp) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                comp.mesReferencia,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.02),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(28)),
                  border: Border(
                      top: BorderSide(
                          color: theme.dividerColor.withOpacity(0.1))),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5))),
                            Text(currency.format(d.valor),
                                style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                    if (Get.find<SessionService>().isFinanceiro) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            controller.toggleStatus(d);
                          },
                          icon: Icon(
                            d.status == 'Pago'
                                ? Icons.pending_rounded
                                : Icons.check_circle_rounded,
                            size: 18,
                            color: d.status == 'Pago'
                                ? Colors.orange
                                : Colors.green,
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: (d.status == 'Pago'
                                    ? Colors.orange
                                    : Colors.green)
                                .withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
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
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: theme.primaryColor.withOpacity(0.8),
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
            size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    color: theme.colorScheme.onSurface.withOpacity(0.4))),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13,
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
                  size: 10, color: color),
              const SizedBox(width: 4),
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 10,
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
