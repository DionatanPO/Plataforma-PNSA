import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../home/controlles/home_controller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores modernas e refinadas
    final backgroundColor = isDark
        ? const Color(0xFF0D0D0D)
        : const Color(0xFFF8F9FA);
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final accentColor = theme.primaryColor;

    // Medidas da tela
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 700 && width < 1100;

    // Configuração de Colunas e Padding
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final padding = isDesktop ? 32.0 : 24.0;

    // Cálculo do aspect ratio dinâmico
    double cardHeightTarget = 220.0; // Aumentado de 200 para 220
    if (!isDesktop) cardHeightTarget = 200.0; // Aumentado de 180 para 200

    final double availableWidth =
        width - (padding * 2) - ((crossAxisCount - 1) * 16);
    final double cardWidth = availableWidth / crossAxisCount;
    final double dynamicAspectRatio = cardWidth / cardHeightTarget;

    // Formatação de data
    String formattedDate;
    try {
      final now = DateTime.now();
      final formatter = DateFormat('EEEE, dd MMMM', 'pt_BR');
      formattedDate = formatter.format(now);
    } catch (e) {
      formattedDate = 'Hoje';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // =======================================================
          // MODERN APP BAR
          // =======================================================
          SliverAppBar(
            toolbarHeight: width < 600 ? 80 : 120,
            titleSpacing: 0,
            floating: true,
            pinned: false,
            snap: true,
            leading: width < 600
                ? IconButton(
                    icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
                    onPressed: () {
                      if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>().scaffoldKey.currentState
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
                width < 600
                    ? 0
                    : padding, // No mobile padding esquerdo é 0 pois tem o leading
                16,
                padding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Ícone com gradiente (Apenas Desktop/Tablet)
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
                          child: Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],

                      // Título e Subtítulo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: GoogleFonts.outfit(
                                fontSize: width < 600
                                    ? 20
                                    : 28, // Tamanho ajustado para mobile
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                            // Subtítulo sempre visível
                            const SizedBox(height: 4),
                            Text(
                              'Visão geral das atividades',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Botões de ação (apenas desktop)
                      if (width > 600) ...[
                        _HeaderAction(
                          icon: Icons.calendar_month_rounded,
                          label: "Mês",
                          theme: theme,
                          borderColor: borderColor,
                        ),
                        const SizedBox(width: 8),
                        _HeaderAction(
                          icon: Icons.file_download_rounded,
                          label: "Exportar",
                          theme: theme,
                          isPrimary: true,
                          accentColor: accentColor,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // =======================================================
          // CARD DE INFORMAÇÕES DA PARÓQUIA
          // =======================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 24, padding, 0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.08),
                      accentColor.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ícone da paróquia
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.church_rounded,
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Informações
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paróquia N. Sra. Auxiliadora',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Iporá, GO',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Badge Admin
                        if (width > 400)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Admin',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Resumo financeiro e atividades recentes',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =======================================================
          // GRID DE CARDS (KPIs)
          // =======================================================
          SliverPadding(
            padding: EdgeInsets.fromLTRB(padding, 24, padding, 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: dynamicAspectRatio,
              ),
              delegate: SliverChildListDelegate([
                _ResponsiveStatCard(
                  title: 'Arrecadação',
                  value: 'R\$ 12.450,00',
                  change: '+12.5%',
                  icon: Icons.trending_up_rounded,
                  color: Colors.green,
                  theme: theme,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                ),
                _ResponsiveStatCard(
                  title: 'Dizimistas',
                  value: '350',
                  subtitle: 'Ativos',
                  change: '',
                  icon: Icons.people_rounded,
                  color: Colors.blue,
                  theme: theme,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                ),
                _ResponsiveStatCard(
                  title: 'Ticket Médio',
                  value: 'R\$ 35,50',
                  change: '-2.0%',
                  isNegative: true,
                  icon: Icons.analytics_rounded,
                  color: Colors.purple,
                  theme: theme,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                ),
              ]),
            ),
          ),

          // =======================================================
          // GRÁFICO DE HISTÓRICO
          // =======================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          Icons.show_chart_rounded,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Histórico de Movimentações',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.05,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.bar_chart_rounded,
                              size: 48,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gráfico em Desenvolvimento',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Visualização de dados em breve',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPONENTES
// =============================================================================

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final bool isPrimary;
  final Color? accentColor;
  final Color? borderColor;

  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.theme,
    this.isPrimary = false,
    this.accentColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      accentColor ?? theme.primaryColor,
                      (accentColor ?? theme.primaryColor).withOpacity(0.8),
                    ],
                  )
                : null,
            color: isPrimary ? null : Colors.transparent,
            border: isPrimary
                ? null
                : Border.all(color: borderColor ?? theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: (accentColor ?? theme.primaryColor).withOpacity(
                        0.3,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
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
        padding: const EdgeInsets.all(16), // Reduzido de 20 para 16
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Parte Superior: Ícone e Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.15),
                        widget.color.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 22),
                ),
                // Badge de Porcentagem
                if (widget.change.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (widget.isNegative ? Colors.red : Colors.green)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isNegative
                              ? Icons.trending_down_rounded
                              : Icons.trending_up_rounded,
                          size: 12,
                          color: widget.isNegative ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.change,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.isNegative
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Valor Principal
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.value,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      widget.subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: widget.theme.colorScheme.onSurface.withOpacity(
                          0.5,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 6),

            // Título
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
