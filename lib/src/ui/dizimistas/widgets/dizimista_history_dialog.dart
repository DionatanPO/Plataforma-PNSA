import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/dizimista_model.dart';
import '../controllers/dizimista_controller.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../../relatorios/controllers/report_controller.dart';

class DizimistaHistoryDialog extends StatelessWidget {
  final Dizimista dizimista;

  const DizimistaHistoryDialog({
    Key? key,
    required this.dizimista,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.find<DizimistaController>();
    final reportController = Get.isRegistered<ReportController>()
        ? Get.find<ReportController>()
        : Get.put(ReportController());

    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 800,
        height: 600,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_edu_rounded,
                      color: theme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico de Contribuições',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${dizimista.nome} • Nº Reg: ${dizimista.numeroRegistro}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.onSurface.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                // Filtramos as contribuições dele no controller de dizimista
                // porque o DizimistaController já mantém a lista syncada.
                // Usamos as contribuições que estão no DizimistaController
                // mas acessamos elas via getter ou propriedade privada se necessário.
                // No DizimistaController as contribuições estão em _contribuicoes.
                // Mas como _contribuicoes é privado, vamos ver se tem getter.
                // Olhando dizimista_controller.dart, não vi getter para contribuições.
                // Vou precisar adicionar um getter ou usar o serviço diretamente.
                // Na verdade, o DizimistaController usa:
                // ContribuicaoService.getAllContribuicoes().listen((contribuicaoList) {
                //   _contribuicoes.assignAll(contribuicaoList);
                // });
                // Mas não expõe _contribuicoes. Vou ver se posso usar o ReportController ou adicionar o getter.

                // Opção 1: Adicionar getter no DizimistaController (melhor)
                // Por agora, vou assumir que vou adicionar o getter lá.

                final historico =
                    controller.historicoContribuicoes(dizimista.id);

                if (historico.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma contribuição encontrada.',
                          style: GoogleFonts.inter(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: historico.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = historico[index];
                    return _HistoryItemCard(
                      contribuicao: c,
                      theme: theme,
                      currency: currency,
                      onReceiptPressed: () =>
                          reportController.downloadOrShareReceiptPdf(c),
                      agentName: controller.getAgentName(c.usuarioId),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final Contribuicao contribuicao;
  final ThemeData theme;
  final NumberFormat currency;
  final String agentName;
  final VoidCallback onReceiptPressed;

  const _HistoryItemCard({
    required this.contribuicao,
    required this.theme,
    required this.currency,
    required this.onReceiptPressed,
    required this.agentName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final dateStr = DateFormat('dd/MM/yyyy').format(contribuicao.dataPagamento);
    final regDateStr =
        DateFormat('dd/MM/yyyy HH:mm').format(contribuicao.dataRegistro);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Ícone do método de pagamento
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getMetodoColor(contribuicao.metodo).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getMetodoIcon(contribuicao.metodo),
              color: _getMetodoColor(contribuicao.metodo),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Info da contribuição
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currency.format(contribuicao.valor),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: contribuicao.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pago em: $dateStr',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (contribuicao.mesesCompetencia.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: contribuicao.mesesCompetencia.map((m) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: Text(
                          _formatMes(m),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (contribuicao.observacao != null &&
                    contribuicao.observacao!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 14,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            contribuicao.observacao!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_pin_rounded,
                        size: 14, color: Colors.blue.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text(
                      'Reg. por: $agentName em $regDateStr',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botão de recibo
          IconButton(
            onPressed: onReceiptPressed,
            tooltip: 'Ver Recibo',
            icon: const Icon(Icons.receipt_long_rounded),
            color: theme.primaryColor,
            style: IconButton.styleFrom(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMetodoIcon(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'pix':
        return Icons.pix_rounded;
      case 'dinheiro':
        return Icons.payments_rounded;
      case 'cartão':
      case 'cartao':
        return Icons.credit_card_rounded;
      case 'transferência':
      case 'transferencia':
        return Icons.account_balance_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getMetodoColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'pix':
        return Colors.teal;
      case 'dinheiro':
        return Colors.green;
      case 'cartão':
      case 'cartao':
        return Colors.blue;
      case 'transferência':
      case 'transferencia':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatMes(String mesRef) {
    try {
      final parts = mesRef.split('-');
      if (parts.length != 2) return mesRef;
      final year = parts[0].substring(2);
      final month = int.parse(parts[1]);
      const months = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez'
      ];
      return '${months[month - 1]}/$year';
    } catch (_) {
      return mesRef;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPago = status == 'Pago';
    final color = isPago ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
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
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
