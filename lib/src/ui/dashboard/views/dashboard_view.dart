import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../home/controlles/home_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  DashboardView({Key? key}) : super(key: key);

  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores modernas e refinadas
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final accentColor = theme.colorScheme.primary;

    // Medidas da tela
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 700 && width < 1100;

    // Configuração de Colunas e Padding
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final padding = isDesktop ? 32.0 : 24.0;

    double cardHeightTarget =
        190.0; // Aumentado para evitar o overflow de 9.4px
    if (isTablet) {
      cardHeightTarget = 210.0;
    } else if (!isDesktop) {
      cardHeightTarget = 185.0; // Aumentado para dar mais folga vertical
    }

    final double availableWidth =
        width - (padding * 2) - ((crossAxisCount - 1) * 16);
    final double cardWidth = availableWidth / crossAxisCount;
    final double dynamicAspectRatio = cardWidth / cardHeightTarget;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value && controller.totalDizimistas == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              toolbarHeight: width < 600
                  ? 90
                  : 130, // Aumentado para evitar overflow no título
              titleSpacing: 0,
              floating: true,
              pinned: false,
              snap: true,
              leading: width < 600
                  ? IconButton(
                      icon:
                          Icon(Icons.menu, color: theme.colorScheme.onSurface),
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
              backgroundColor: surfaceColor,
              elevation: 0,
              title: Padding(
                padding: EdgeInsets.fromLTRB(
                  width < 600 ? 16 : padding,
                  16,
                  padding,
                  16,
                ),
                child: Row(
                  children: [
                    if (width >= 600) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor,
                              accentColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.dashboard_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: GoogleFonts.outfit(
                              fontSize: width < 600 ? 20 : 28,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Visão geral das atividades',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 24, padding, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =======================================================
                    // RESUMO FINANCEIRO (DIA, MÊS, ANO)
                    // =======================================================
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Resumo Financeiro',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: dynamicAspectRatio,
                        children: [
                          _ResponsiveStatCard(
                            title: 'Arrecadação Hoje',
                            value: controller
                                .formatCurrency(controller.arrecadacaoDia),
                            change: '',
                            icon: Icons.today_rounded,
                            color: Colors.teal,
                            theme: theme,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                          ),
                          _ResponsiveStatCard(
                            title: 'Arrecadação Mês',
                            value: controller
                                .formatCurrency(controller.arrecadacaoMesAtual),
                            change: controller
                                .formatPercent(controller.variacaoArrecadacao),
                            isNegative: controller.variacaoArrecadacao < 0,
                            icon: Icons.calendar_month_rounded,
                            color: Colors.green,
                            theme: theme,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                          ),
                          _ResponsiveStatCard(
                            title: 'Arrecadação Ano',
                            value: controller
                                .formatCurrency(controller.arrecadacaoAno),
                            change: '',
                            icon: Icons.event_note_rounded,
                            color: Colors.blueAccent,
                            theme: theme,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 32),

                    // =======================================================
                    // STATUS DOS FIÉIS
                    // =======================================================
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Status dos Fiéis',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: dynamicAspectRatio,
                        children: [
                          _ResponsiveStatCard(
                            title: 'Fiéis Ativos',
                            value: controller.ativosDizimistas.toString(),
                            subtitle: '${controller.totalDizimistas} Total',
                            change: '',
                            icon: Icons.check_circle_outline_rounded,
                            color: Colors.blue,
                            theme: theme,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                          ),
                          _ResponsiveStatCard(
                            title: 'Fiéis Inativos',
                            value: controller.inativosDizimistas.toString(),
                            change: '',
                            icon: Icons.pause_circle_outline_rounded,
                            color: Colors.orange,
                            theme: theme,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                          ),
                          _ResponsiveStatCard(
                            title: 'Fiéis Afastados',
                            value: controller.afastadosDizimistas.toString(),
                            change: '',
                            icon: Icons.error_outline_rounded,
                            color: Colors.redAccent,
                            theme: theme,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            // =======================================================
            // ATIVIDADES RECENTES
            // =======================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 40, padding, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                color: accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Contribuições Recentes',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => _showHistoryDialog(context),
                          icon: const Icon(Icons.list_alt_rounded, size: 18),
                          label: Text(
                            'Ver tudo',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: controller.ultimasContribuicoes.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40),
                              child: Center(
                                child: Text(
                                  'Nenhuma contribuição registrada recentemente.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.ultimasContribuicoes.length,
                              separatorBuilder: (context, index) => Divider(
                                color: borderColor,
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final c =
                                    controller.ultimasContribuicoes[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        accentColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    c.dizimistaNome,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${c.tipo} • ${c.metodo} • ${DateFormat('dd/MM/yyyy HH:mm').format(c.dataRegistro)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    controller.formatCurrency(c.valor),
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final accentColor = theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              // Header do Dialog
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.history_rounded,
                          color: theme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Histórico de Contribuições',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Lista completa de todos os lançamentos',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              // Campo de Busca
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  onChanged: (value) => controller.searchTerms.value = value,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, tipo, método ou usuário...',
                    prefixIcon: Icon(Icons.search_rounded, color: accentColor),
                    filled: true,
                    fillColor: accentColor.withOpacity(0.02),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: accentColor.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: accentColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Lista
              Expanded(
                child: Obx(() {
                  final list = controller.filteredContribuicoes;

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum registro encontrado',
                            style: GoogleFonts.inter(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final c = list[index];
                      final agentName = controller.getAgentName(c.usuarioId);
                      final agentFunc =
                          controller.getAgentFunction(c.usuarioId);
                      final width = MediaQuery.of(context).size.width;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: width < 800
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.dizimistaNome,
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${c.tipo} • ${c.metodo}',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        controller.formatCurrency(c.valor),
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.person_pin_rounded,
                                                size: 14, color: Colors.blue),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                agentName,
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            DateFormat('dd/MM HH:mm')
                                                .format(c.dataRegistro),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => controller
                                                .downloadOrShareReceiptPdf(c),
                                            icon: const Icon(
                                                Icons.receipt_long_rounded,
                                                size: 20),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            tooltip: 'Gerar Recibo',
                                            color: theme.primaryColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.dizimistaNome,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.tipo,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      c.metodo,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.person_pin_rounded,
                                                size: 14, color: Colors.blue),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                agentName,
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          agentFunc,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () => controller
                                                  .downloadOrShareReceiptPdf(c),
                                              icon: const Icon(
                                                  Icons.receipt_long_rounded,
                                                  size: 20),
                                              tooltip: 'Gerar Recibo',
                                              color: theme.primaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              controller
                                                  .formatCurrency(c.valor),
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateFormat('dd/MM/yy HH:mm')
                                              .format(c.dataRegistro),
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String change;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final bool isNegative;
  final Color surfaceColor;
  final Color borderColor;

  const _ResponsiveStatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.change,
    required this.icon,
    required this.color,
    required this.theme,
    required this.surfaceColor,
    required this.borderColor,
    this.isNegative = false,
  });

  @override
  State<_ResponsiveStatCard> createState() => _ResponsiveStatCardState();
}

class _ResponsiveStatCardState extends State<_ResponsiveStatCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovering
                ? widget.color.withOpacity(0.4)
                : widget.borderColor,
            width: _isHovering ? 2 : 1,
          ),
          boxShadow: [
            if (_isHovering)
              BoxShadow(
                color: widget.color.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 22),
                ),
                if (widget.change.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (widget.isNegative ? Colors.red : Colors.green)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.change,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.isNegative ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.value,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          widget.theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '• ${widget.subtitle}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          widget.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ThemeData>('theme', widget.theme));
  }
}
