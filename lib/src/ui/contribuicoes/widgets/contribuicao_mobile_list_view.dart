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
