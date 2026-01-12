import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/modern_header.dart';
import '../models/dizimista_model.dart';
import '../controllers/dizimista_controller.dart';
import '../../contribuicoes/models/contribuicao_model.dart';
import '../../relatorios/controllers/report_controller.dart';

class DizimistaHistoryView extends StatefulWidget {
  const DizimistaHistoryView({Key? key}) : super(key: key);

  @override
  State<DizimistaHistoryView> createState() => _DizimistaHistoryViewState();
}

class _DizimistaHistoryViewState extends State<DizimistaHistoryView> {
  late Dizimista dizimista;
  final controller = Get.find<DizimistaController>();
  late ReportController reportController;
  late int displayedYear;

  @override
  void initState() {
    super.initState();
    dizimista = Get.arguments as Dizimista;
    displayedYear = DateTime.now().year;
    reportController = Get.isRegistered<ReportController>()
        ? Get.find<ReportController>()
        : Get.put(ReportController());
  }

  List<Contribuicao> get _historico =>
      controller.historicoContribuicoes(dizimista.id);

  bool _isMonthPaid(int month) {
    final monthStr = month.toString().padLeft(2, '0');
    final target = '$displayedYear-$monthStr';

    return _historico.any((c) {
      if (c.status != 'Pago') return false;
      if (c.mesesCompetencia.contains(target)) return true;
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

    try {
      // First try to find by competency month (regardless of status)
      return _historico.firstWhere((c) => c.mesesCompetencia.contains(target));
    } catch (_) {
      try {
        // Fallback: If no competency, try payment date (only if PAID)
        // If it's pending, it might not have valid payment date yet for that month context
        return _historico.firstWhere((c) =>
            c.status == 'Pago' &&
            c.mesesCompetencia.isEmpty &&
            c.dataPagamento.year == displayedYear &&
            c.dataPagamento.month == month);
      } catch (e) {
        return null;
      }
    }
  }

  double _getTotalForYear() {
    double total = 0;
    for (int i = 1; i <= 12; i++) {
      final c = _getContributionForMonth(i);
      if (c != null && c.status == 'Pago') total += c.valor;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          ModernHeader(
            title: 'Cartão do Dizimista',
            subtitle: '${dizimista.nome} • Visualização Anual',
            icon: Icons.calendar_month_rounded,
            showBackButton: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Year Control & Summary
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;

                        final yearSelector = Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => setState(() => displayedYear--),
                              icon: const Icon(Icons.chevron_left_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ano de Referência',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                                Text(
                                  '$displayedYear',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () => setState(() => displayedYear++),
                              icon: const Icon(Icons.chevron_right_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
                              ),
                            ),
                          ],
                        );

                        final totalSummary = Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: theme.primaryColor.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: isMobile
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total em $displayedYear',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                              Text(
                                currency.format(_getTotalForYear()),
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );

                        if (isMobile) {
                          return Column(
                            children: [
                              yearSelector,
                              const SizedBox(height: 16),
                              totalSummary,
                            ],
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            yearSelector,
                            totalSummary,
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calendar Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final isMobile = width < 600;
                      final isDesktop = width >= 1100;

                      final crossAxisCount = isMobile ? 1 : (isDesktop ? 6 : 4);
                      final aspectRatio =
                          isMobile ? 3.5 : (isDesktop ? 2.1 : 1.9);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isPaid = _isMonthPaid(month);
                          final item = _getContributionForMonth(month);
                          final monthNames = [
                            'JAN',
                            'FEV',
                            'MAR',
                            'ABR',
                            'MAI',
                            'JUN',
                            'JUL',
                            'AGO',
                            'SET',
                            'OUT',
                            'NOV',
                            'DEZ'
                          ];

                          return _MonthCard(
                            monthName: monthNames[index],
                            isPaid: isPaid,
                            contribuicao: item,
                            theme: theme,
                            currency: currency,
                            reportController: reportController,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => reportController.downloadOrShareDizimistaHistoryPdf(
            dizimista, _historico),
        label: Text(
          'Exportar Histórico',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.picture_as_pdf_rounded),
        backgroundColor: theme.primaryColor,
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final String monthName;
  final bool isPaid;
  final Contribuicao? contribuicao;
  final ThemeData theme;
  final NumberFormat currency;
  final ReportController reportController;

  const _MonthCard({
    required this.monthName,
    required this.isPaid,
    required this.contribuicao,
    required this.theme,
    required this.currency,
    required this.reportController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    // Determinar Status e Estilos
    final bool hasContribution = contribuicao != null;
    final bool isActuallyPaid =
        hasContribution && contribuicao!.status == 'Pago';
    final bool isPending = hasContribution && !isActuallyPaid;

    Color bgColor;
    Color borderColor;
    Color textColor;
    String statusLabel;

    if (isActuallyPaid) {
      // PAGO - Verde
      bgColor = isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50;
      borderColor = Colors.green.withOpacity(0.3);
      textColor = Colors.green.shade800;
      statusLabel = 'PAGO';
    } else if (isPending) {
      // PENDENTE (A RECEBER) - Laranja
      bgColor = isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50;
      borderColor = Colors.orange.withOpacity(0.3);
      textColor = Colors.orange.shade900;
      statusLabel = 'A RECEBER';
    } else {
      // SEM CONTRIBUIÇÃO - Cinza
      bgColor = isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50;
      borderColor = theme.dividerColor.withOpacity(0.1);
      textColor = theme.colorScheme.onSurface.withOpacity(0.4);
      statusLabel = ''; // Não mostra badge, ou mostra texto "Vazio"
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mês
              Text(
                monthName,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActuallyPaid || isPending
                      ? textColor
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),

              // Valor e Botão (se existir contribuição)
              if (hasContribution)
                Row(
                  children: [
                    Text(
                      currency.format(contribuicao!.valor),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        onPressed: () => reportController
                            .downloadOrShareReceiptPdf(contribuicao!),
                        icon: const Icon(Icons.print_rounded),
                        tooltip: 'Imprimir Recibo',
                        color: textColor,
                        style: IconButton.styleFrom(
                          backgroundColor: textColor.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Espaço vazio para manter altura
                SizedBox(height: 16),
            ],
          ),

          const Spacer(),

          // Rodapé do Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Esquerda: Data ou Texto de "Sem Contribuição"
              // Esquerda: Data ou Texto de "Sem Contribuição"
              if (hasContribution)
                // Data de Pagamento (ou previsão se pendente)
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(contribuicao!.dataPagamento),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                )
              else
                // Texto informativo
                Text(
                  'Não houve contribuição',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),

              // Direita: Badge de Status (apenas se tiver contribuição)
              if (hasContribution)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActuallyPaid
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
