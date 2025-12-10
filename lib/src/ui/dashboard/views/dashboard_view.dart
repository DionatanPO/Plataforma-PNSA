import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Controle de scroll para desktop
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores de fundo mais refinadas para desktop
    final backgroundColor = isDark ? const Color(0xFF181818) : const Color(0xFFF9F9F9);
    final surfaceColor = isDark ? const Color(0xFF252525) : Colors.white;

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 700 && width < 1100;

    // Define quantas colunas na grid
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
    final padding = isDesktop ? 40.0 : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true, // Essencial para Desktop
        thickness: 8,
        radius: const Radius.circular(4),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER FLUTUANTE
            SliverAppBar(
              backgroundColor: backgroundColor.withOpacity(0.95),
              surfaceTintColor: Colors.transparent,
              pinned: true,
              floating: true,
              elevation: 0,
              toolbarHeight: 90,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: padding, vertical: 0),
                title: LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard',
                                    style: GoogleFonts.outfit(
                                      fontSize: isDesktop ? 32 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (isDesktop)
                                    Text(
                                      'Visão geral de desempenho em tempo real',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Ações de Topo (Filtros)
                            if (constraints.maxWidth > 600) ...[
                              _HeaderAction(icon: Icons.calendar_today_rounded, label: "Este Mês", theme: theme),
                              const SizedBox(width: 12),
                              _HeaderAction(icon: Icons.download_rounded, label: "Exportar", theme: theme, isPrimary: true),
                            ]
                          ],
                        ),
                      );
                    }
                ),
              ),
            ),

            // 2. GRID DE MÉTRICAS (STAT CARDS)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(padding, 24, padding, 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.8 : 2.2, // Ajuste para ficar retangular elegante
                ),
                delegate: SliverChildListDelegate([
                  _DesktopStatCard(
                    title: 'Receita Total',
                    value: 'R\$ 152.4k',
                    change: '+12.5%',
                    icon: Icons.attach_money_rounded,
                    color: Colors.green,
                    theme: theme,
                    surfaceColor: surfaceColor,
                  ),
                  _DesktopStatCard(
                    title: 'Novos Clientes',
                    value: '1,250',
                    change: '+5.2%',
                    icon: Icons.group_add_rounded,
                    color: Colors.blue,
                    theme: theme,
                    surfaceColor: surfaceColor,
                  ),
                  _DesktopStatCard(
                    title: 'Pedidos',
                    value: '843',
                    change: '-2.1%',
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.orange,
                    theme: theme,
                    isNegative: true,
                    surfaceColor: surfaceColor,
                  ),
                  _DesktopStatCard(
                    title: 'Taxa de Conversão',
                    value: '3.8%',
                    change: '+0.4%',
                    icon: Icons.pie_chart_outline_rounded,
                    color: Colors.purple,
                    theme: theme,
                    surfaceColor: surfaceColor,
                  ),
                ]),
              ),
            ),

            // 3. SEÇÃO PRINCIPAL (Gráfico + Lista Lateral se Desktop)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: isDesktop
                    ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gráfico (Ocupa 65% da tela)
                      Expanded(
                        flex: 2,
                        child: _ChartSection(theme: theme, surfaceColor: surfaceColor),
                      ),
                      const SizedBox(width: 24),
                      // Lista Lateral (Ocupa 35%)
                      Expanded(
                        flex: 1,
                        child: _RecentActivityList(theme: theme, surfaceColor: surfaceColor),
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    _ChartSection(theme: theme, surfaceColor: surfaceColor),
                    const SizedBox(height: 24),
                    _RecentActivityList(theme: theme, surfaceColor: surfaceColor),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// COMPONENTES REUTILIZÁVEIS E MODERNOS
// =============================================================================

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final bool isPrimary;

  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.theme,
    this.isPrimary = false
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? theme.primaryColor : theme.colorScheme.surfaceContainerHighest;
    final contentColor = isPrimary ? Colors.white : theme.colorScheme.onSurface;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          border: isPrimary ? null : Border.all(color: theme.dividerColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: contentColor.withOpacity(isPrimary ? 1 : 0.7)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: contentColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final bool isNegative;
  final Color surfaceColor;

  const _DesktopStatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.theme,
    required this.surfaceColor,
    this.isNegative = false,
  });

  @override
  State<_DesktopStatCard> createState() => _DesktopStatCardState();
}

class _DesktopStatCardState extends State<_DesktopStatCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovering
                ? widget.color.withOpacity(0.5)
                : widget.theme.dividerColor.withOpacity(0.1),
            width: _isHovering ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? widget.color.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isHovering ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 22),
                ),
                // Badge de Porcentagem
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (widget.isNegative ? Colors.red : Colors.green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          widget.isNegative ? Icons.trending_down : Icons.trending_up,
                          size: 14,
                          color: widget.isNegative ? Colors.red : Colors.green
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.change,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.isNegative ? Colors.red : Colors.green,
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: widget.theme.colorScheme.onSurface,
              ),
            ),
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  final ThemeData theme;
  final Color surfaceColor;

  const _ChartSection({required this.theme, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Análise de Receita',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Icon(Icons.more_horiz, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Comparativo Jan - Jun 2025',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _SmoothChartPainter(theme),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final ThemeData theme;
  final Color surfaceColor;

  const _RecentActivityList({required this.theme, required this.surfaceColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400, // Altura igual a do gráfico para alinhar no desktop
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atividades Recentes',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              physics: const NeverScrollableScrollPhysics(), // Scroll controlado pelo pai
              separatorBuilder: (c, i) => Divider(height: 24, color: theme.dividerColor.withOpacity(0.1)),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        index.isEven ? Icons.arrow_downward : Icons.arrow_upward,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index.isEven ? 'Recebimento Pix' : 'Pagamento Fornecedor',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Hoje, 14:3${index}',
                            style: GoogleFonts.inter(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      index.isEven ? '+ R\$ 250,00' : '- R\$ 120,50',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: index.isEven ? Colors.green : theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Ver tudo',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Pintor de Gráfico Bezier (Reuso do código que fiz antes, ajustado)
class _SmoothChartPainter extends CustomPainter {
  final ThemeData theme;
  _SmoothChartPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.primaryColor.withOpacity(0.2),
          theme.primaryColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Grid simples
    final gridPaint = Paint()..color = theme.dividerColor.withOpacity(0.1)..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      double y = i * (size.height / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Dados fictícios
    final values = [0.2, 0.4, 0.3, 0.7, 0.5, 0.8, 0.6];
    final stepX = size.width / (values.length - 1);

    final path = Path();
    path.moveTo(0, size.height * (1 - values[0]));

    for (int i = 1; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - values[i]);
      final prevX = (i - 1) * stepX;
      final prevY = size.height * (1 - values[i - 1]);

      final controlX1 = prevX + (stepX / 2);
      final controlY1 = prevY;
      final controlX2 = x - (stepX / 2);
      final controlY2 = y;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
    }

    canvas.drawPath(path, paint);

    // Fechar para pintar o preenchimento
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}