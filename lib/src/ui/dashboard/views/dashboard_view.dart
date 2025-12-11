import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
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

    final backgroundColor = isDark ? const Color(0xFF181818) : const Color(0xFFF9F9F9);
    final surfaceColor = isDark ? const Color(0xFF252525) : Colors.white;

    // Medidas da tela
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 700 && width < 1100;

    // Configuração de Colunas e Padding
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final padding = isDesktop ? 32.0 : 16.0;

    // =========================================================================
    // LÓGICA MÁGICA DO ASPECT RATIO (CORREÇÃO DOS CARDS)
    // =========================================================================
    // Queremos que os cards tenham uma altura visualmente agradável (ex: ~180px)
    // independentemente da largura da tela.
    // Fórmula: (LarguraTotal - Paddings) / NumeroColunas / AlturaDesejada

    double cardHeightTarget = 200.0; // Altura fixa alvo para o card
    if (!isDesktop) cardHeightTarget = 180.0; // Mobile pode ser um pouco menor

    // Calcula a largura disponível para os cards
    final double availableWidth = width - (padding * 2) - ((crossAxisCount - 1) * 16);
    final double cardWidth = availableWidth / crossAxisCount;

    // Define a proporção baseada na largura real do card vs altura desejada
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
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: isDesktop,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER (Full Width novamente)
            SliverAppBar(
              backgroundColor: backgroundColor.withOpacity(0.98),
              surfaceTintColor: Colors.transparent,
              pinned: true,
              floating: true,
              elevation: 0,
              toolbarHeight: 90,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Painel Geral',
                                style: GoogleFonts.outfit(
                                  fontSize: isDesktop ? 28 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Visão Geral',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (width > 600) ...[
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              _HeaderAction(icon: Icons.calendar_today_rounded, label: "Mês", theme: theme),
                              const SizedBox(width: 8),
                              _HeaderAction(icon: Icons.download_rounded, label: "Exportar", theme: theme, isPrimary: true),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. CARD DE BOAS VINDAS (No corpo, Full Width com padding)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 16, padding, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Iporá, GO',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Admin',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Resumo financeiro e atividades recentes.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. GRID DE CARDS (KPIs) COM ALTURA CONTROLADA
            SliverPadding(
              padding: EdgeInsets.fromLTRB(padding, 24, padding, 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  // AQUI ESTÁ A CORREÇÃO PRINCIPAL:
                  // Usamos a variável calculada lá em cima.
                  // Se a tela for larga, o ratio aumenta (ex: 3.0), achatando o card.
                  // Se a tela for estreita, o ratio diminui (ex: 1.5).
                  childAspectRatio: dynamicAspectRatio,
                ),
                delegate: SliverChildListDelegate([
                  _ResponsiveStatCard(
                    title: 'Arrecadação',
                    value: 'R\$ 12.450,00',
                    change: '+12.5%',
                    icon: Icons.attach_money_rounded,
                    color: Colors.green,
                    theme: theme,
                    surfaceColor: surfaceColor,
                  ),
                  _ResponsiveStatCard(
                    title: 'Dizimistas',
                    value: '350 Ativos',
                    change: '',
                    icon: Icons.group_rounded,
                    color: Colors.blue,
                    theme: theme,
                    surfaceColor: surfaceColor,
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
                  ),
                ]),
              ),
            ),

            // 4. GRÁFICO
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padding, 0, padding, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Histórico de Movimentações',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: Center(
                        child: Text(
                          'Gráfico',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
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
    );
  }
}

// =============================================================================
// COMPONENTES (Card Otimizado para redimensionamento)
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
          border: isPrimary ? null : Border.all(color: theme.dividerColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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

class _ResponsiveStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final bool isNegative;
  final Color surfaceColor;

  const _ResponsiveStatCard({
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovering ? widget.color.withOpacity(0.5) : widget.theme.dividerColor.withOpacity(0.1),
            width: _isHovering ? 1.5 : 1,
          ),
          boxShadow: [
            if (_isHovering)
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
          ],
        ),
        // Usamos Column com alinhamento otimizado
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Parte Superior: Ícone e Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
                // Badge de Porcentagem (Opcional)
                if (widget.change.isNotEmpty)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (widget.isNegative ? Colors.red : Colors.green).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.change,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.isNegative ? Colors.red : Colors.green,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
              ],
            ),

            // Espaçador flexível (ajuda se o card ficar alto demais em mobile)
            const Spacer(),

            // Valor Principal (FittedBox segura a onda se o card estreitar)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.value,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Título
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 14,
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