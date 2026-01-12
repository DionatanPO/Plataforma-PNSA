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

    return DefaultTabController(
      length: 2,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          width: 800,
          height: 700,
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
                child: Column(
                  children: [
                    Row(
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
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
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
                    const SizedBox(height: 24),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                        labelStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        tabs: const [
                          Tab(text: 'Visualização em Lista'),
                          Tab(text: 'Visualização em Calendário'),
                        ],
                        dividerColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Obx(() {
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
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return TabBarView(
                    children: [
                      _HistoryListView(
                        historico: historico,
                        theme: theme,
                        currency: currency,
                        reportController: reportController,
                        controller: controller,
                      ),
                      _HistoryCalendarView(
                        historico: historico,
                        theme: theme,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryListView extends StatelessWidget {
  final List<Contribuicao> historico;
  final ThemeData theme;
  final NumberFormat currency;
  final ReportController reportController;
  final DizimistaController controller;

  const _HistoryListView({
    required this.historico,
    required this.theme,
    required this.currency,
    required this.reportController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: historico.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = historico[index];
        return _HistoryItemCard(
          contribuicao: c,
          theme: theme,
          currency: currency,
          onReceiptPressed: () => reportController.downloadOrShareReceiptPdf(c),
          agentName: controller.getAgentName(c.usuarioId),
        );
      },
    );
  }
}

class _HistoryCalendarView extends StatefulWidget {
  final List<Contribuicao> historico;
  final ThemeData theme;

  const _HistoryCalendarView({
    required this.historico,
    required this.theme,
  });

  @override
  State<_HistoryCalendarView> createState() => _HistoryCalendarViewState();
}

class _HistoryCalendarViewState extends State<_HistoryCalendarView> {
  late int displayedYear;

  @override
  void initState() {
    super.initState();
    displayedYear = DateTime.now().year;
  }

  bool _isMonthPaid(int month) {
    // Format required: YYYY-MM (e.g., 2024-03)
    // Month is 1-12
    final monthStr = month.toString().padLeft(2, '0');
    final target = '$displayedYear-$monthStr';

    return widget.historico.any((c) {
      if (c.status != 'Pago') return false;
      // Check competences
      if (c.mesesCompetencia.contains(target)) return true;

      // Fallback: Check payment date if no competence
      if (c.mesesCompetencia.isEmpty) {
        return c.dataPagamento.year == displayedYear &&
            c.dataPagamento.month == month;
      }
      return false;
    });
  }

  Contribuicao? _getContributionForMonth(int month) {
    final monthStr = month.toString().padLeft(2, '0');
    final target = '$displayedYear-$monthStr';

    // Try to find by competence first
    try {
      return widget.historico.firstWhere(
          (c) => c.status == 'Pago' && c.mesesCompetencia.contains(target));
    } catch (_) {
      // Fallback
      try {
        return widget.historico.firstWhere((c) =>
            c.status == 'Pago' &&
            c.mesesCompetencia.isEmpty &&
            c.dataPagamento.year == displayedYear &&
            c.dataPagamento.month == month);
      } catch (e) {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Year Navigation
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() => displayedYear--),
                icon: const Icon(Icons.chevron_left_rounded),
                color: widget.theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Text(
                '$displayedYear',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => setState(() => displayedYear++),
                icon: const Icon(Icons.chevron_right_rounded),
                color: widget.theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns = 4 rows (12 months)
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isPaid = _isMonthPaid(month);
              final item = _getContributionForMonth(month);
              final monthNames = [
                'Janeiro',
                'Fevereiro',
                'Março',
                'Abril',
                'Maio',
                'Junho',
                'Julho',
                'Agosto',
                'Setembro',
                'Outubro',
                'Novembro',
                'Dezembro'
              ];

              return Container(
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.1)
                      : widget.theme.colorScheme.onSurface.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPaid
                        ? Colors.green.withOpacity(0.3)
                        : widget.theme.dividerColor.withOpacity(0.1),
                    width: isPaid ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            monthNames[index],
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isPaid
                                  ? Colors.green.shade700
                                  : widget.theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isPaid)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 20),
                            )
                          else
                            Icon(
                              Icons.close_rounded,
                              color: widget.theme.colorScheme.onSurface
                                  .withOpacity(0.1),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                    if (isPaid && item != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Tooltip(
                          message:
                              'Pago em ${DateFormat('dd/MM').format(item.dataPagamento)} via ${item.metodo}',
                          child: Icon(Icons.info_outline_rounded,
                              size: 16, color: Colors.green.withOpacity(0.7)),
                        ),
                      )
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
