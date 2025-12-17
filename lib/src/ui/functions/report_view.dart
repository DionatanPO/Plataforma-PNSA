import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../home/controlles/home_controller.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _period = 'Este Mês';
  final List<String> _periods = [
    'Esta Semana',
    'Este Mês',
    'Este Trimestre',
    'Este Ano',
  ];

  // Controle de Hover para os cards (simples gerenciamento de estado)
  int _hoveredCardIndex = -1;

  final ScrollController _scrollController =
      ScrollController(); // Controller adicionado

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
    final primaryColor = theme.primaryColor;

    // Fundo refinado
    final backgroundColor = isDark
        ? const Color(0xFF181818)
        : const Color(0xFFFAFAFA);

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
                          Get.find<HomeController>().scaffoldKey.currentState
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
                    Text(
                      'Relatório',
                      style: GoogleFonts.outfit(
                        fontSize: size.width < 600 ? 20 : 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Visão geral de desempenho e métricas',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [],
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 20,
                vertical: 24,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // STAT CARDS (Com animação Staggered)
                  _buildAnimatedSection(
                    index: 0,
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                child: _HoverStatCard(
                                  title: 'Total Arrecadado',
                                  value: 'R\$ 45.2k',
                                  change: '+8.3%',
                                  isPositive: true,
                                  icon: Icons.attach_money,
                                  color: Colors.green,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _HoverStatCard(
                                  title: 'Dízimos',
                                  value: 'R\$ 28.5k',
                                  change: '+5.2%',
                                  isPositive: true,
                                  icon: Icons.money_outlined,
                                  color: Colors.blue,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _HoverStatCard(
                                  title: 'Ofertas',
                                  value: 'R\$ 12.3k',
                                  change: '+15.7%',
                                  isPositive: true,
                                  icon: Icons.volunteer_activism_outlined,
                                  color: Colors.purple,
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _HoverStatCard(
                                  title: 'Despesas',
                                  value: 'R\$ 23.1k',
                                  change: '-3.2%',
                                  isPositive: false,
                                  icon: Icons.money_off_outlined,
                                  color: Colors.red,
                                  theme: theme,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _HoverStatCard(
                                title: 'Total Arrecadado',
                                value: 'R\$ 45.2k',
                                change: '+8.3%',
                                isPositive: true,
                                icon: Icons.attach_money,
                                color: Colors.green,
                                theme: theme,
                              ),
                              const SizedBox(height: 16),
                              _HoverStatCard(
                                title: 'Dízimos',
                                value: 'R\$ 28.5k',
                                change: '+5.2%',
                                isPositive: true,
                                icon: Icons.money_outlined,
                                color: Colors.blue,
                                theme: theme,
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 32),

                  // CHART SECTION (Gráfico suave)
                  _buildAnimatedSection(
                    index: 1,
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF202020) : Colors.white,
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Evolução Financeira',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Receitas e despesas mensais',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              // Legenda simples
                              Row(
                                children: [
                                  _ChartLegend(
                                    label: "Receitas",
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 16),
                                  _ChartLegend(
                                    label: "Despesas",
                                    color: Colors.grey.withOpacity(0.3),
                                    isDashed: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Expanded(child: _SmoothLineChart(theme: theme)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // TABLES SECTION
                  _buildAnimatedSection(
                    index: 2,
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _ModernTableCard(
                                  title: 'Receitas Recentais',
                                  headers: const [
                                    'ID',
                                    'Fiéis',
                                    'Tipo',
                                    'Valor',
                                  ],
                                  rows: const [
                                    [
                                      '#REC-001',
                                      'Maria Santos',
                                      'Dízimo',
                                      'R\$ 300',
                                    ],
                                    [
                                      '#REC-002',
                                      'Carlos Oliveira',
                                      'Oferta',
                                      'R\$ 150',
                                    ],
                                    [
                                      '#REC-003',
                                      'Ana Costa',
                                      'Dízimo',
                                      'R\$ 200',
                                    ],
                                    [
                                      '#REC-004',
                                      'Pedro Silva',
                                      'Doação',
                                      'R\$ 500',
                                    ],
                                    [
                                      '#REC-005',
                                      'Lucia Ferreira',
                                      'Dízimo',
                                      'R\$ 180',
                                    ],
                                  ],
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _ModernTableCard(
                                  title: 'Despesas Recentes',
                                  headers: const ['ID', 'Categoria', 'Valor'],
                                  rows: const [
                                    ['#DES-001', 'Alimentação', 'R\$ 2.500'],
                                    ['#DES-002', 'Manutenção', 'R\$ 1.800'],
                                    ['#DES-003', 'Salários', 'R\$ 8.500'],
                                    ['#DES-004', 'Materiais', 'R\$ 950'],
                                    ['#DES-005', 'Serviços', 'R\$ 1.200'],
                                  ],
                                  theme: theme,
                                ),
                              ),
                            ],
                          )
                        : _ModernTableCard(
                            title: 'Receitas Recentais',
                            headers: const ['ID', 'Fiéis', 'Tipo', 'Valor'],
                            rows: const [
                              ['#REC-001', 'Maria Santos', 'Dízimo', 'R\$ 300'],
                              [
                                '#REC-002',
                                'Carlos Oliveira',
                                'Oferta',
                                'R\$ 150',
                              ],
                            ],
                            theme: theme,
                          ),
                  ),
                  const SizedBox(height: 60),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para animação em cascata
  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
          .animate(
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

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconOnly extends StatelessWidget {
  final IconData icon;
  final ThemeData theme;

  const _HeaderIconOnly({required this.icon, required this.theme});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20,
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      onPressed: () {},
      splashRadius: 20,
      tooltip: 'Ação',
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
  final bool reverseColor;

  const _HoverStatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
    required this.theme,
    this.reverseColor = false,
  });

  @override
  State<_HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<_HoverStatCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;
    // O status (verde/vermelho) muda se for reverseColor (ex: cancelamento subir é ruim)
    final statusColor = widget.reverseColor
        ? (widget.isPositive ? Colors.red : Colors.green)
        : (widget.isPositive ? Colors.green : Colors.red);

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

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDashed;

  const _ChartLegend({
    required this.label,
    required this.color,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed ? Border.all(color: Colors.grey, width: 2) : null,
            shape: BoxShape.circle,
          ),
          child: isDashed ? const Center(child: SizedBox()) : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _ModernTableCard extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final ThemeData theme;

  const _ModernTableCard({
    required this.title,
    required this.headers,
    required this.rows,
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
          // Cabeçalho
          Row(
            children: headers
                .map(
                  (h) => Expanded(
                    child: Text(
                      h,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Divider(color: theme.dividerColor.withOpacity(0.1)),
          // Linhas com Hover Effect Interno
          ...rows.map((row) => _TableRow(row: row, theme: theme)).toList(),
        ],
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  final List<String> row;
  final ThemeData theme;

  const _TableRow({required this.row, required this.theme});

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _isHovering
              ? widget.theme.primaryColor.withOpacity(0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: widget.row.map((cell) {
            // Lógica simples para detectar se é coluna de Status e renderizar Badge
            if ([
              'Dízimo',
              'Oferta',
              'Doação',
              'Concluído',
              'Pendente',
              'Alimentação',
              'Manutenção',
              'Salários',
              'Materiais',
              'Serviços',
              'Recebido',
              'Processando',
              'Estornado',
            ].contains(cell)) {
              return Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(status: cell),
                ),
              );
            }
            return Expanded(
              child: Text(
                cell,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: widget.theme.colorScheme.onSurface.withOpacity(0.9),
                ),
              ),
            );
          }).toList(),
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

// Custom Painter para Gráfico Suave (Curva de Bezier)
class _SmoothLineChart extends StatelessWidget {
  final ThemeData theme;
  const _SmoothLineChart({required this.theme});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SmoothChartPainter(theme),
      size: Size.infinite,
    );
  }
}

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

    // Grid Lines (Minimalistas)
    final gridPaint = Paint()
      ..color = theme.dividerColor.withOpacity(0.1)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      double y = i * (size.height / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Pontos do Gráfico
    final values = [0.8, 0.5, 0.6, 0.3, 0.7, 0.4, 0.6];
    final stepX = size.width / (values.length - 1);

    final path = Path();
    path.moveTo(0, size.height * (1 - values[0]));

    for (int i = 1; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - values[i]);
      final prevX = (i - 1) * stepX;
      final prevY = size.height * (1 - values[i - 1]);

      // Curva de Bezier para suavizar
      final controlX1 = prevX + (stepX / 2);
      final controlY1 = prevY;
      final controlX2 = x - (stepX / 2);
      final controlY2 = y;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
    }

    // Desenhar preenchimento
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Desenhar linha
    canvas.drawPath(path, paint);

    // Desenhar Tooltip simulado no último ponto
    final lastX = size.width;
    final lastY = size.height * (1 - values.last);

    canvas.drawCircle(
      Offset(lastX, lastY),
      5,
      Paint()..color = theme.primaryColor,
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      10,
      Paint()..color = theme.primaryColor.withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
