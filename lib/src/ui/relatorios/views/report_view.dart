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
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(3),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // APP BAR MODERNO
            SliverAppBar(
              backgroundColor: backgroundColor.withOpacity(0.9),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 20, vertical: 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Relatórios Financeiros',
                      style: GoogleFonts.outfit(
                        fontSize: size.width < 600 ? 18 : 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Obx(() {
                      if (controller.isCompetenceMode.value) {
                        return Text(
                          'Referência: ${controller.selectedCompetenceMonth.value}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }
                      if (controller.isRangeMode.value &&
                          controller.selectedRange.value != null) {
                        final start = DateFormat('dd/MM/yy')
                            .format(controller.selectedRange.value!.start);
                        final end = DateFormat('dd/MM/yy')
                            .format(controller.selectedRange.value!.end);
                        return Text(
                          'Período: $start até $end',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }
                      return Text(
                        'Fluxo de Caixa: ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              leading: !isDesktop
                  ? IconButton(
                      icon:
                          Icon(Icons.menu, color: theme.colorScheme.onSurface),
                      onPressed: () => Get.find<HomeController>()
                          .scaffoldKey
                          .currentState
                          ?.openDrawer(),
                    )
                  : null,
              actions: [
                IconButton(
                  tooltip: 'Exportar em PDF',
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  color: theme.primaryColor,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () => controller.downloadOrShareDailyReportPdf(),
                ),
                const SizedBox(width: 20),
              ],
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 16,
                vertical: 16,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. SELETOR DE MODO (PROFISSIONAL)
                  _buildAnimatedSection(
                    index: 0,
                    child: _buildModeToggle(context),
                  ),
                  const SizedBox(height: 24),

                  // 2. HERO STATS (GRANDES NÚMEROS)
                  _buildAnimatedSection(
                    index: 1,
                    child: _buildHeroStats(context),
                  ),
                  const SizedBox(height: 24),

                  // 3. DETALHAMENTO DE PAGAMENTO
                  _buildAnimatedSection(
                    index: 2,
                    child: _buildPaymentMethodStrip(context),
                  ),
                  const SizedBox(height: 32),

                  // 4. LISTA DE TRANSAÇÕES
                  _buildAnimatedSection(
                    index: 3,
                    child: Obx(() {
                      final lista = controller.contribuicoes.toList();
                      return _ModernTableCard(
                        title: controller.isCompetenceMode.value
                            ? 'Lançamentos Vinculados ao Mês'
                            : 'Entradas Reais do Dia',
                        contribuicoes: lista,
                        onReceiptPressed: (c) =>
                            controller.downloadOrShareReceiptPdf(c),
                        theme: theme,
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // 5. SEÇÃO DE AJUDA
                  _buildAnimatedSection(
                    index: 4,
                    child: _buildHelpSection(context),
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
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

  Widget _buildModeToggle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final isComp = controller.isCompetenceMode.value;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _ToggleItem(
                      label: 'Relatório de Caixa',
                      subtitle: 'O que foi pago no dia/período',
                      isSelected: !isComp,
                      icon: Icons.payments_rounded,
                      activeColor: Colors.green,
                      onTap: () {
                        controller.isCompetenceMode.value = false;
                        controller
                            .fetchDailyReport(controller.selectedDate.value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ToggleItem(
                      label: 'Relatório de Competência',
                      subtitle: 'Dízimos de um mês específico',
                      isSelected: isComp,
                      icon: Icons.calendar_view_month_rounded,
                      activeColor: Colors.blue,
                      onTap: () => _showCompetencePicker(context),
                    ),
                  ),
                ],
              ),
            ),
            if (!isComp)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    Text(
                      'Data:',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) controller.updateDate(date);
                      },
                      icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                      label: Text(DateFormat('dd/MM/yyyy')
                          .format(controller.selectedDate.value)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          initialDateRange: controller.selectedRange.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (range != null) controller.updateRange(range);
                      },
                      icon: const Icon(Icons.date_range_rounded, size: 16),
                      label: const Text('Período'),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Meses que estamos vendo:',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => _showCompetencePicker(context),
                      icon: const Icon(Icons.calendar_month_rounded, size: 16),
                      label: Text(controller.selectedCompetenceMonth.value),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildHeroStats(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return Obx(() => Row(
          children: [
            Expanded(
              child: _HeroStatCard(
                title: 'Total Recebido',
                value: currency.format(controller.totalArrecadado.value),
                icon: Icons.trending_up_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HeroStatCard(
                title: 'Ação do Dia',
                value: '${controller.contribuicoes.length} Lanç.',
                icon: Icons.receipt_long_rounded,
                color: Colors.blue,
              ),
            ),
          ],
        ));
  }

  Widget _buildPaymentMethodStrip(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Obx(() => Row(
            children: [
              _MiniStat(
                label: 'Dinheiro',
                value: currency.format(controller.totalDinheiro.value),
                icon: Icons.payments_outlined,
                color: Colors.green,
              ),
              _MiniStat(
                label: 'Pix',
                value: currency.format(controller.totalPix.value),
                icon: Icons.pix_rounded,
                color: Colors.teal,
              ),
              _MiniStat(
                label: 'Cartão',
                value: currency.format(controller.totalCartao.value),
                icon: Icons.credit_card_rounded,
                color: Colors.blue,
              ),
              _MiniStat(
                label: 'Transf.',
                value: currency.format(controller.totalTransferencia.value),
                icon: Icons.account_balance_rounded,
                color: Colors.orange,
              ),
            ],
          )),
    );
  }

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

  void _showCompetencePicker(BuildContext context) async {
    final now = DateTime.now();
    // Parse current selection
    final currentParts = controller.selectedCompetenceMonth.value.split('-');
    int selectedYear = int.tryParse(currentParts[0]) ?? now.year;
    int selectedMonth = int.tryParse(currentParts[1]) ?? now.month;

    await Get.dialog(
      StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(
            'Mês de Referência',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(10, (index) => now.year - 5 + index)
                      .map((y) =>
                          DropdownMenuItem(value: y, child: Text(y.toString())))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedYear = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (index) => index + 1)
                      .map((m) => DropdownMenuItem(
                          value: m, child: Text(m.toString().padLeft(2, '0'))))
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedMonth = val!),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                controller.isCompetenceMode.value = true;
                controller.selectedCompetenceMonth.value =
                    '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}';
                Get.back();
              },
              child: const Text('Filtrar'),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Entenda os Relatórios',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        _HelpCard(
          title: 'O que entrou Hoje (Fluxo de Caixa)',
          description:
              'Este relatório mostra o dinheiro real que entrou na paróquia na data selecionada. É ideal para conferir o caixa físico, conferir PIX e depósitos feitos no dia.',
          icon: Icons.payments_rounded,
          color: Colors.green,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _HelpCard(
          title: 'Dízimo por Mês (Competência)',
          description:
              'Mostra a arrecadação vinculada ao mês de referência do dízimo. Se um fiel pagar 3 meses atrasados hoje, este relatório dividirá os valores nos meses correspondentes. Ideal para análise contábil.',
          icon: Icons.calendar_view_month_rounded,
          color: Colors.blue,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _HelpCard(
          title: 'Exportação em PDF',
          description:
              'Utilize o botão de PDF no topo para gerar um documento oficial pronto para impressão ou compartilhamento via WhatsApp/E-mail.',
          icon: Icons.picture_as_pdf_rounded,
          color: Colors.red,
          theme: theme,
        ),
      ],
    );
  }
}

// =============================================================================
// COMPONENTES MODERNOS E REUTILIZÁVEIS
// =============================================================================

class _ToggleItem extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final IconData icon;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.icon,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colorToUse =
        activeColor ?? theme.primaryColor; // Usa a cor ativa ou padrão

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorToUse
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorToUse : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : colorToUse.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : colorToUse,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : theme.colorScheme.onSurface.withOpacity(0.5),
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

class _HeroStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HeroStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              Icon(icon, color: color.withOpacity(0.5), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
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

class _HelpCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _HelpCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
