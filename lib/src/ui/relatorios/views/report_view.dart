import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../home/controlles/home_controller.dart';
import '../controllers/report_controller.dart';
import '../../contribuicoes/models/contribuicao_model.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> with TickerProviderStateMixin {
  late AnimationController _animationController;

  final ScrollController _scrollController =
      ScrollController(); // Controller adicionado

  final ReportController controller = Get.put(ReportController());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose(); // Dispose do controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    // Fundo refinado
    final backgroundColor =
        isDark ? const Color(0xFF181818) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Scrollbar(
        // Item essencial para Desktop
        controller: _scrollController, // Controller vinculado
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(4),
        child: CustomScrollView(
          controller: _scrollController, // Controller vinculado
          physics: const BouncingScrollPhysics(),
          slivers: [
            // HEADER FLUTUANTE ESTILO MACOS/WINDOWS
            SliverAppBar(
              backgroundColor: backgroundColor.withOpacity(0.95),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              pinned: false,
              floating: true,
              snap: true,
              toolbarHeight: size.width < 600 ? 80 : 100,
              leading: !isDesktop
                  ? IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () {
                        if (Get.isRegistered<HomeController>()) {
                          Get.find<HomeController>()
                              .scaffoldKey
                              .currentState
                              ?.openDrawer();
                        } else {
                          Scaffold.of(context).openDrawer();
                        }
                      },
                    )
                  : null,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width < 600
                      ? 0
                      : 24, // Matches ModernHeader/Dashboard logic
                  16,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() {
                      if (controller.isRangeMode.value &&
                          controller.selectedRange.value != null) {
                        final start = DateFormat('dd/MM/yy')
                            .format(controller.selectedRange.value!.start);
                        final end = DateFormat('dd/MM/yy')
                            .format(controller.selectedRange.value!.end);
                        return Text(
                          'Relatório: $start - $end',
                          style: GoogleFonts.outfit(
                            fontSize: size.width < 600 ? 20 : 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        );
                      }
                      return Text(
                        'Relatório Diário - ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)}',
                        style: GoogleFonts.outfit(
                          fontSize: size.width < 600 ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      );
                    }),
                    Text(
                      'Visão geral de contribuições do dia',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Escolher Dia',
                  icon: const Icon(Icons.calendar_today_outlined),
                  color: theme.colorScheme.onSurface,
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      controller.updateDate(date);
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Escolher Período',
                  icon: const Icon(Icons.date_range_outlined),
                  color: theme.colorScheme.onSurface,
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      initialDateRange: controller.selectedRange.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: theme.copyWith(
                            colorScheme: theme.colorScheme.copyWith(
                              primary: theme.primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (range != null) {
                      controller.updateRange(range);
                    }
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 20,
                vertical: 24,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // PAYMENT METHODS SUMMARY
                  _buildAnimatedSection(
                    index: 0,
                    child: Obx(() {
                      final currency = NumberFormat.simpleCurrency(
                        locale: 'pt_BR',
                      );
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF202020) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detalhes por Forma de Pagamento',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 24,
                              runSpacing: 24,
                              children: [
                                _PaymentDetailItem(
                                  theme: theme,
                                  label: 'Dinheiro',
                                  icon: Icons.money,
                                  value: controller.totalDinheiro.value,
                                  currency: currency,
                                  color: Colors.green,
                                ),
                                _PaymentDetailItem(
                                  theme: theme,
                                  label: 'Pix',
                                  icon: Icons.pix,
                                  value: controller.totalPix.value,
                                  currency: currency,
                                  color: Colors.teal,
                                ),
                                _PaymentDetailItem(
                                  theme: theme,
                                  label: 'Cartão',
                                  icon: Icons.credit_card,
                                  value: controller.totalCartao.value,
                                  currency: currency,
                                  color: Colors.blue,
                                ),
                                _PaymentDetailItem(
                                  theme: theme,
                                  label: 'Transferência',
                                  icon: Icons.account_balance,
                                  value: controller.totalTransferencia.value,
                                  currency: currency,
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Divider(color: theme.dividerColor.withOpacity(0.1)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Geral',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currency.format(
                                    controller.totalArrecadado.value,
                                  ),
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // TABLES SECTION
                  _buildAnimatedSection(
                    index: 1,
                    child: Obx(() {
                      // .toList() forces GetX to register dependency in the builder
                      final lista = controller.contribuicoes.toList();

                      return _ModernTableCard(
                        title: 'Contribuições do Dia',
                        contribuicoes: lista,
                        onReceiptPressed: (c) =>
                            controller.downloadOrShareReceiptPdf(c),
                        theme: theme,
                      );
                    }),
                  ),
                  const SizedBox(height: 60),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'report_fab',
        onPressed: () {
          _showExportModal(context);
        },
        icon: const Icon(Icons.file_upload),
        label: const Text('Exportar Relatório'),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  void _showExportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Exportar Relatório',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  title: Text(
                    'Imprimir / Salvar PDF',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Gera um PDF pronto para impressão',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close modal
                    controller.generateDailyReportPdf();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      kIsWeb ? Icons.download : Icons.share,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(
                    kIsWeb ? 'Baixar PDF' : 'Compartilhar PDF',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    kIsWeb
                        ? 'Faz o download do arquivo para seu dispositivo'
                        : 'Envia o arquivo PDF para outros apps',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close modal
                    controller.downloadOrShareDailyReportPdf();
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper para animação em cascata
  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutQuart),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: child,
      ),
    );
  }
}

// =============================================================================
// COMPONENTES MODERNOS E REUTILIZÁVEIS
// =============================================================================

class _PaymentDetailItem extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final IconData icon;
  final double value;
  final NumberFormat currency;
  final Color color;

  const _PaymentDetailItem({
    required this.theme,
    required this.label,
    required this.icon,
    required this.value,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(value),
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _HoverStatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  State<_HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<_HoverStatCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;
    final statusColor = widget.isPositive ? Colors.green : Colors.red;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovering ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202020) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovering
                ? widget.color.withOpacity(0.5)
                : widget.theme.dividerColor.withOpacity(0.1),
            width: _isHovering ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? widget.color.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isHovering ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.isPositive
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.change,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.value,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: widget.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernTableCard extends StatelessWidget {
  final String title;
  final List<Contribuicao> contribuicoes;
  final Function(Contribuicao) onReceiptPressed;
  final ThemeData theme;

  const _ModernTableCard({
    required this.title,
    required this.contribuicoes,
    required this.onReceiptPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202020) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver tudo',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Cabeçalho alinhado com o corpo
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Nome',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Tipo',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Pagamento',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Valor',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(width: 100), // Espaço para coluna de Ações
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: theme.dividerColor.withOpacity(0.1)),
          // Linhas com Hover Effect Interno
          if (contribuicoes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Nenhuma contribuição registrada para este dia.',
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
            )
          else
            ...contribuicoes.map(
              (c) => _TableRow(
                contribuicao: c,
                onReceiptPressed: () => onReceiptPressed(c),
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  final Contribuicao contribuicao;
  final VoidCallback onReceiptPressed;
  final ThemeData theme;

  const _TableRow({
    required this.contribuicao,
    required this.onReceiptPressed,
    required this.theme,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: _isHovering
              ? widget.theme.primaryColor.withOpacity(0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Nome
            Expanded(
              flex: 2,
              child: Text(
                widget.contribuicao.dizimistaNome.isNotEmpty
                    ? widget.contribuicao.dizimistaNome
                    : 'Anônimo',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
            ),
            // Tipo
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusBadge(status: widget.contribuicao.tipo),
              ),
            ),
            // Método
            Expanded(
              child: Text(
                widget.contribuicao.metodo,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            // Valor
            Expanded(
              child: Text(
                currency.format(widget.contribuicao.valor),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.theme.colorScheme.primary,
                ),
              ),
            ),
            // Ações
            SizedBox(
              width: 100,
              child: IconButton(
                onPressed: widget.onReceiptPressed,
                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                tooltip: 'Gerar Recibo',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: widget.theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Dízimo':
      case 'Dízimo Regular':
      case 'Dízimo Atrasado':
      case 'Oferta':
      case 'Doação':
      case 'Concluído':
      case 'Recebido':
      case 'Salários':
        color = Colors.green;
        break;
      case 'Pendente':
      case 'Processando':
      case 'Alimentação':
      case 'Materiais':
        color = Colors.blue;
        break;
      case 'Estornado':
        color = Colors.red;
        break;
      case 'Manutenção':
      case 'Serviços':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
