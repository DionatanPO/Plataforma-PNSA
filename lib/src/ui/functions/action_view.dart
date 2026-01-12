import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// VIEW PRINCIPAL RESPONSIVA
// ============================================================================
class DesktopComponentsView extends StatefulWidget {
  const DesktopComponentsView({super.key});

  @override
  State<DesktopComponentsView> createState() => _DesktopComponentsViewState();
}

class _DesktopComponentsViewState extends State<DesktopComponentsView> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.dashboard_outlined,
      'label': 'Cards & Layout',
      'id': 'cards',
    },
    {
      'icon': Icons.touch_app_outlined,
      'label': 'Botões & Ações',
      'id': 'buttons',
    },
    {
      'icon': Icons.table_chart_outlined,
      'label': 'Dados & Tabelas',
      'id': 'data',
    },
    {
      'icon': Icons.input_outlined,
      'label': 'Formulários & Inputs',
      'id': 'inputs',
    },
    {
      'icon': Icons.feedback_outlined,
      'label': 'Feedback & Status',
      'id': 'feedback',
    },
    {
      'icon': Icons.animation_rounded,
      'label': 'Animações & Efeitos',
      'id': 'animations',
    },
    {
      'icon': Icons.smart_button,
      'label': 'Botões Animados',
      'id': 'animated_buttons',
    },
    {
      'icon': Icons.palette_outlined,
      'label': 'Cores & Tipografia',
      'id': 'colors',
    },
    {
      'icon': Icons.alt_route_rounded,
      'label': 'Fluxos & Estados',
      'id': 'flows',
    },
    {
      'icon': Icons.layers_outlined,
      'label': 'Interface Avançada',
      'id': 'advanced_ui',
    },
    {
      'icon': Icons.calendar_month_outlined,
      'label': 'Data & Hora',
      'id': 'date_time',
    },
  ];

  void _onMenuSelected(int index) {
    setState(() => _selectedIndex = index);
    // Se for mobile (Drawer estiver aberto), fecha o drawer ao selecionar
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Breakpoint para Mobile vs Desktop
    final isDesktop = size.width >= 900;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3);
    final sidebarColor = isDark ? const Color(0xFF252525) : Colors.white;

    // Conteúdo da Sidebar (Extraído para reutilizar no Drawer)
    final sidebarContent = _SidebarContent(
      selectedIndex: _selectedIndex,
      onSelected: _onMenuSelected,
      categories: _categories,
      theme: theme,
      bgColor: sidebarColor,
    );

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgColor,
        resizeToAvoidBottomInset: false,
        // 1. APP BAR (Apenas no Mobile)
        appBar: isDesktop
            ? null
            : AppBar(
                backgroundColor: bgColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                title: Text(
                  "UI Kit",
                  style: GoogleFonts.outfit(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        // 2. DRAWER (Apenas no Mobile)
        drawer: isDesktop
            ? null
            : Drawer(backgroundColor: sidebarColor, child: sidebarContent),
        body: Row(
          children: [
            // 3. SIDEBAR FIXA (Apenas no Desktop)
            if (isDesktop) SizedBox(width: 260, child: sidebarContent),

            // 4. ÁREA DE CONTEÚDO
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  // Padding dinâmico
                  padding: EdgeInsets.only(
                    left: isDesktop ? 60 : 20,
                    right: isDesktop ? 60 : 20,
                    top: isDesktop ? 60 : 20,
                    bottom: (isDesktop ? 60 : 20) + bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _categories[_selectedIndex]['label'],
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Exemplos de componentes e seus estados.",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Renderiza conteúdo passando isDesktop para ajustes finos
                      _buildCategoryContent(
                        index: _selectedIndex,
                        theme: theme,
                        context: context,
                        isDesktop: isDesktop,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent({
    required int index,
    required ThemeData theme,
    required BuildContext context,
    required bool isDesktop,
  }) {
    switch (index) {
      case 0:
        return _CardsLayoutSection(theme: theme, isDesktop: isDesktop);
      case 1:
        return _ButtonsActionsSection(theme: theme);
      case 2:
        return _DataTablesSection(theme: theme);
      case 3:
        return _InputsFormsSection(theme: theme, isDesktop: isDesktop);
      case 4:
      case 5:
        return _AnimationsSection(theme: theme);
      case 6:
        return _ButtonAnimationsSection(theme: theme);
      case 7:
        return _ColorsTypographySection(
          theme: theme,
        ); // Ajuste o índice conforme necessário
      case 8:
        return _FlowsAndStatesSection(theme: theme);
      case 9:
        return _AdvancedUISection(theme: theme);
      case 10:
        return _DatePickersSection(theme: theme, context: context);
      default:
        return const Text("Seção em construção");
    }
  }
}

// ============================================================================
// WIDGET: SIDEBAR CONTENT (Reutilizável)
// ============================================================================
class _SidebarContent extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelected;
  final List<Map<String, dynamic>> categories;
  final ThemeData theme;
  final Color bgColor;

  const _SidebarContent({
    required this.selectedIndex,
    required this.onSelected,
    required this.categories,
    required this.theme,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "UI Kit",
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  "System Components",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = categories[index];
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    onTap: () => onSelected(index),
                    selected: isSelected,
                    selectedTileColor: theme.primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: Icon(
                      item['icon'],
                      color: isSelected
                          ? theme.primaryColor
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      size: 20,
                    ),
                    title: Text(
                      item['label'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    dense: true,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "v2.0 Responsive",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SEÇÕES (ADAPTADAS PARA MOBILE)
// ============================================================================

class _CardsLayoutSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _CardsLayoutSection({required this.theme, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. CARDS PADRÃO (Mantidos) ---
        Text(
          "Cards de Informação (Standard)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            DesktopCard(
              width: isDesktop ? 320 : double.infinity,
              title: "Relatório Financeiro",
              subtitle: "Atualizado há 2 horas",
              icon: Icons.pie_chart,
              child: Text(
                "Visualize o balanço mensal e as projeções.",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              onTap: () {},
            ),
            DesktopCard(
              width: isDesktop ? 320 : double.infinity,
              title: "Segurança",
              subtitle: "Sistema Protegido",
              icon: Icons.shield_outlined,
              iconColor: Colors.green,
              child: Text(
                "Todas as verificações de segurança passaram.",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 40),

        // --- 2. CARDS COM IMAGEM (Media) ---
        Text(
          "Cards de Mídia (Blog/Produto)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            DesktopImageCard(
              width: isDesktop ? 300 : double.infinity,
              imageUrl:
                  "https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=600&auto=format&fit=crop",
              tag: "Tecnologia",
              title: "O Futuro do Desenvolvimento",
              description:
                  "Descubra como novas ferramentas estão moldando a forma como codificamos.",
              onTap: () {},
            ),
            DesktopImageCard(
              width: isDesktop ? 300 : double.infinity,
              imageUrl:
                  "https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=600&auto=format&fit=crop",
              tag: "Analytics",
              title: "Crescimento de Dados",
              description:
                  "Análise profunda sobre o big data no mercado corporativo.",
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 40),

        // --- 3. CARDS COM AÇÃO E PERFIL ---
        Text(
          "Cards de Ação e Perfil",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            // Action Card (Convite)
            DesktopActionCard(
              width: isDesktop ? 350 : double.infinity,
              title: "Convite de Equipe",
              icon: Icons.group_add_outlined,
              content:
                  "Lucas convidou você para participar do projeto 'Dashboard 2026'.",
              primaryActionLabel: "Aceitar",
              secondaryActionLabel: "Recusar",
              onPrimaryAction: () {},
              onSecondaryAction: () {},
            ),

            // Profile Card (Usuário)
            DesktopProfileCard(
              width: isDesktop ? 300 : double.infinity,
              name: "Julia Martins",
              role: "Senior Product Designer",
              imageUrl:
                  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop",
              stats: const {
                "Projetos": "12",
                "Seguidores": "1.4k",
                "Score": "98",
              },
            ),
          ],
        ),

        const SizedBox(height: 40),

        Text(
          "Containers & Estrutura",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const DesktopFileUploadZone(),
      ],
    );
  }
}

class _ButtonsActionsSection extends StatelessWidget {
  final ThemeData theme;

  const _ButtonsActionsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Botões Principais",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DesktopButton(
              label: "Salvar Alterações",
              onPressed: () {},
              color: Colors.green,
            ),
            DesktopButton(
              label: "Cancelar",
              isOutlined: true,
              onPressed: () {},
              color: Colors.red,
            ),
            DesktopButton(
              label: "Exportar PDF",
              icon: Icons.picture_as_pdf,
              onPressed: () {},
              color: Colors.redAccent,
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "Abas Segmentadas (Tabs)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        // Adiciona scroll horizontal se as tabs forem muitas para a tela mobile
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DesktopSegmentedTabs(
            tabs: const [
              "Visão Geral",
              "Analise",
              "Configurações",
              "Logs",
              "Extra",
            ],
            onTabChanged: (i) {},
          ),
        ),
      ],
    );
  }
}

class _DataTablesSection extends StatelessWidget {
  final ThemeData theme;

  const _DataTablesSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tabela Avançada",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        // Scroll horizontal para tabelas no Mobile
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 800, // Largura mínima da tabela
            child: const DesktopTable(
              headers: [
                "Usuário",
                "Status",
                "Função",
                "Último Acesso",
                "Ações",
              ],
              rows: [
                ["Ana Silva", "Ativo", "Admin", "Há 2 horas", "actions"],
                ["Carlos Souza", "Pendente", "Editor", "Ontem", "actions"],
                [
                  "Beatriz Lima",
                  "Inativo",
                  "Viewer",
                  "20 Ago, 2026",
                  "actions",
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          "Indicadores Circulares",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 32,
          runSpacing: 32,
          children: [
            DesktopCircularLoader(
              percentage: 0.75,
              label: "CPU",
              color: Colors.blue,
            ),
            DesktopCircularLoader(
              percentage: 0.45,
              label: "RAM",
              color: Colors.purple,
            ),
            DesktopCircularLoader(
              percentage: 0.90,
              label: "SSD",
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}

class _InputsFormsSection extends StatelessWidget {
  final ThemeData theme;
  final bool isDesktop;

  const _InputsFormsSection({required this.theme, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Controles de Seleção",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          width: isDesktop ? 500 : double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const DesktopSwitchTile(
                title: "Modo Avião",
                subtitle: "Desativar conexões",
                initialValue: false,
              ),
              Divider(height: 32, color: theme.dividerColor.withOpacity(0.1)),
              const DesktopSwitchTile(
                title: "Notificações",
                subtitle: "Mostrar popups",
                initialValue: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Text(
          "Navegação (Breadcrumbs)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: const DesktopBreadcrumb(
            items: ["Dashboard", "Vendas", "Relatórios", "Detalhes #8420"],
          ),
        ),
      ],
    );
  }
}

class _FeedbackStatusSection extends StatelessWidget {
  final ThemeData theme;
  final BuildContext context;
  final bool isDesktop;

  const _FeedbackStatusSection({
    required this.theme,
    required this.context,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Barras de Progresso",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          width: isDesktop ? 600 : double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: const Column(
            children: [
              DesktopProgressBar(
                label: "Upload",
                percentage: 0.75,
                color: Colors.blue,
              ),
              SizedBox(height: 24),
              DesktopProgressBar(
                label: "Instalação",
                percentage: 1.0,
                color: Colors.green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Text(
          "Skeleton Loading",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        // Layout Responsivo para Skeletons
        isDesktop
            ? const Row(
                children: [
                  Expanded(child: DesktopSkeletonCard()),
                  SizedBox(width: 24),
                  Expanded(child: DesktopSkeletonCard()),
                ],
              )
            : const Column(
                children: [
                  DesktopSkeletonCard(),
                  SizedBox(height: 16),
                  DesktopSkeletonCard(),
                ],
              ),
        const SizedBox(height: 40),
        Text(
          "Alertas & Diálogos",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            FilledButton(
              onPressed: () => showDesktopDialog(
                context: context,
                title: "Excluir Arquivo?",
                content: "Esta ação não pode ser desfeita.",
                type: DialogType.danger,
                onConfirm: () {},
              ),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Alerta Perigo"),
            ),
            FilledButton(
              onPressed: () => showDesktopDialog(
                context: context,
                title: "Atualização",
                content: "Nova versão disponível.",
                type: DialogType.success,
                onConfirm: () {},
              ),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Alerta Sucesso"),
            ),
          ],
        ),
      ],
    );
  }
}

class DesktopCircularLoader extends StatelessWidget {
  final double percentage;
  final String label;
  final Color color;

  const DesktopCircularLoader({
    super.key,
    required this.percentage,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                color: theme.dividerColor.withOpacity(0.1),
                strokeWidth: 8,
              ),
              CircularProgressIndicator(
                value: percentage,
                color: color,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Text(
                  "${(percentage * 100).toInt()}%",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class DesktopBreadcrumb extends StatelessWidget {
  final List<String> items;

  const DesktopBreadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;
        final isLast = index == items.length - 1;
        return Row(
          children: [
            InkWell(
              onTap: isLast ? null : () {},
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                    color: isLast
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class DesktopFileUploadZone extends StatefulWidget {
  const DesktopFileUploadZone({super.key});

  @override
  State<DesktopFileUploadZone> createState() => _DesktopFileUploadZoneState();
}

class _DesktopFileUploadZoneState extends State<DesktopFileUploadZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.primaryColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color:
              _isHovering ? color.withOpacity(0.05) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovering ? color : theme.dividerColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isHovering
                    ? color.withOpacity(0.1)
                    : theme.dividerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: _isHovering
                    ? color
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Clique para upload ou arraste e solte",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "SVG, PNG, JPG ou GIF (max. 10MB)",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopSwitchTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool initialValue;

  const DesktopSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialValue,
  });

  @override
  State<DesktopSwitchTile> createState() => _DesktopSwitchTileState();
}

class _DesktopSwitchTileState extends State<DesktopSwitchTile> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => value = !value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 28,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: value
                  ? theme.primaryColor
                  : theme.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCirc,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DesktopSkeletonCard extends StatefulWidget {
  const DesktopSkeletonCard({super.key});

  @override
  State<DesktopSkeletonCard> createState() => _DesktopSkeletonCardState();
}

class _DesktopSkeletonCardState extends State<DesktopSkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.04);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.5 + (_controller.value * 0.5);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Opacity(
            opacity: opacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum DialogType { info, success, warning, danger }

void showDesktopDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  DialogType type = DialogType.info,
  String? confirmText,
  String cancelText = "Cancelar",
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Fechar",
    pageBuilder: (context, anim1, anim2) => Container(),
    transitionBuilder: (context, anim1, anim2, child) {
      final curvedValue = Curves.easeInOutBack.transform(anim1.value) - 1.0;
      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
        child: Opacity(
          opacity: anim1.value,
          child: _DesktopDialogWidget(
            title: title,
            content: content,
            onConfirm: onConfirm,
            type: type,
            confirmText: confirmText,
            cancelText: cancelText,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class _DesktopDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final DialogType type;
  final String? confirmText;
  final String cancelText;

  const _DesktopDialogWidget({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.type,
    this.confirmText,
    required this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color accentColor;
    IconData icon;
    String defaultBtnText;
    switch (type) {
      case DialogType.danger:
        accentColor = Colors.red;
        icon = Icons.warning_rounded;
        defaultBtnText = "Excluir";
        break;
      case DialogType.success:
        accentColor = Colors.green;
        icon = Icons.check_circle_rounded;
        defaultBtnText = "Confirmar";
        break;
      case DialogType.warning:
        accentColor = Colors.orange;
        icon = Icons.info_outline_rounded;
        defaultBtnText = "Entendi";
        break;
      case DialogType.info:
      default:
        accentColor = theme.primaryColor;
        icon = Icons.info_outline_rounded;
        defaultBtnText = "OK";
        break;
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accentColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        confirmText ?? defaultBtnText,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isOutlined;
  final IconData? icon;

  const DesktopButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isOutlined = false,
    this.icon,
  });

  @override
  State<DesktopButton> createState() => _DesktopButtonState();
}

class _DesktopButtonState extends State<DesktopButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isOutlined
              ? (_isHovering
                  ? widget.color.withOpacity(0.1)
                  : Colors.transparent)
              : (_isHovering ? widget.color.withOpacity(0.9) : widget.color),
          borderRadius: BorderRadius.circular(8),
          border: widget.isOutlined ? Border.all(color: widget.color) : null,
          boxShadow: (!widget.isOutlined && _isHovering)
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isOutlined ? widget.color : Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: widget.isOutlined ? widget.color : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopProgressBar extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const DesktopProgressBar({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              "${(percentage * 100).toInt()}%",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.dividerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  width: constraints.maxWidth * percentage,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DesktopSegmentedTabs extends StatefulWidget {
  final List<String> tabs;
  final ValueChanged<int> onTabChanged;

  const DesktopSegmentedTabs({
    super.key,
    required this.tabs,
    required this.onTabChanged,
  });

  @override
  State<DesktopSegmentedTabs> createState() => _DesktopSegmentedTabsState();
}

class _DesktopSegmentedTabsState extends State<DesktopSegmentedTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.tabs.length, (index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onTabChanged(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF3E3E3E) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                widget.tabs[index],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DesktopTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;

  const DesktopTable({super.key, required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: headers
                  .map(
                    (h) => Expanded(
                      child: Text(
                        h.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: theme.colorScheme.onSurface.withOpacity(
                            0.5,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
          ...rows.asMap().entries.map((entry) {
            return _DesktopTableRow(
              cells: entry.value,
              theme: theme,
              isLast: entry.key == rows.length - 1,
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _DesktopTableRow extends StatefulWidget {
  final List<String> cells;
  final ThemeData theme;
  final bool isLast;

  const _DesktopTableRow({
    required this.cells,
    required this.theme,
    required this.isLast,
  });

  @override
  State<_DesktopTableRow> createState() => _DesktopTableRowState();
}

class _DesktopTableRowState extends State<_DesktopTableRow> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _isHovering
            ? widget.theme.primaryColor.withOpacity(0.04)
            : Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: widget.cells.map((cell) {
                  if (cell == 'actions') {
                    return Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () {},
                            color: Colors.blue,
                            tooltip: "Editar",
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () {},
                            color: Colors.red,
                            tooltip: "Excluir",
                          ),
                        ],
                      ),
                    );
                  }
                  if (['Ativo', 'Inativo', 'Pendente'].contains(cell)) {
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
                        fontSize: 14,
                        color:
                            widget.theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (!widget.isLast)
              Divider(
                height: 1,
                color: widget.theme.dividerColor.withOpacity(0.05),
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
      case 'Ativo':
        color = Colors.green;
        break;
      case 'Inativo':
        color = Colors.grey;
        break;
      case 'Pendente':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
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

// WIDGETS COMPONENTES (COPIADOS E MANTIDOS)
// ============================================================================

class DesktopCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final VoidCallback? onTap;
  final double width;

  const DesktopCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
    this.iconColor,
    this.onTap,
    this.width = 280,
  });

  @override
  State<DesktopCard> createState() => _DesktopCardState();
}

class _DesktopCardState extends State<DesktopCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _isHovering
        ? theme.primaryColor.withOpacity(0.5)
        : theme.dividerColor.withOpacity(0.1);
    final shadowColor = _isHovering
        ? theme.primaryColor.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          transform: Matrix4.translationValues(0, _isHovering ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: _isHovering ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (widget.iconColor ?? theme.primaryColor)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor ?? theme.primaryColor,
                        size: 22,
                      ),
                    ),
                    if (_isHovering)
                      Icon(
                        Icons.arrow_outward,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SEÇÃO 6: ANIMAÇÕES & EFEITOS
// ============================================================================
class _AnimationsSection extends StatelessWidget {
  final ThemeData theme;

  const _AnimationsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Efeito 3D Tilt (Mouse Tracking)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            DesktopTiltCard(
              title: "Cartão Premium",
              subtitle: "Mova o mouse sobre mim",
              icon: Icons.diamond_outlined,
              color: Colors.purple,
            ),
            DesktopTiltCard(
              title: "Segurança",
              subtitle: "Interatividade física",
              icon: Icons.shield_moon_outlined,
              color: Colors.teal,
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "Painéis Expansíveis (Accordion)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          width: 600,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              DesktopExpansionPanel(
                title: "Detalhes do Servidor",
                content:
                    "CPU: Intel i9 12900K\nRAM: 64GB DDR5\nStorage: 2TB NVMe SSD\nUptime: 99.9%",
                icon: Icons.dns_outlined,
              ),
              Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
              DesktopExpansionPanel(
                title: "Configurações de Rede",
                content:
                    "IP: 192.168.1.50\nSubnet: 255.255.255.0\nGateway: 192.168.1.1\nDNS: 8.8.8.8",
                icon: Icons.wifi,
                initiallyExpanded: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Text(
          "Indicadores Pulsantes (Alertas)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DesktopPulseBadge(
              color: Colors.red,
              icon: Icons.notifications_active,
            ),
            const SizedBox(width: 32),
            DesktopPulseBadge(color: Colors.green, icon: Icons.wifi),
            const SizedBox(width: 32),
            DesktopPulseBadge(color: Colors.blue, icon: Icons.radar),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// COMPONENTE 12: DESKTOP TILT CARD (Efeito 3D)
// ============================================================================
class DesktopTiltCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const DesktopTiltCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  State<DesktopTiltCard> createState() => _DesktopTiltCardState();
}

class _DesktopTiltCardState extends State<DesktopTiltCard>
    with SingleTickerProviderStateMixin {
  // Variáveis para controlar a rotação
  double x = 0;
  double y = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) => setState(() {
        // Reseta a posição quando o mouse sai
        x = 0;
        y = 0;
      }),
      onHover: (hoverEvent) {
        // Calcula a posição do mouse relativa ao centro do card
        // Tamanho fixo do card definido abaixo é 260x180
        final dx = hoverEvent.localPosition.dx - (260 / 2);
        final dy = hoverEvent.localPosition.dy - (180 / 2);

        // Aplica sensibilidade
        setState(() {
          x = -dy * 0.005; // Inverte Y para rotação X
          y = dx * 0.005; // X afeta rotação Y
        });
      },
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspectiva
          ..rotateX(x)
          ..rotateY(y),
        alignment: FractionalOffset.center,
        child: Container(
          width: 260,
          height: 180,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(
                  y * 10,
                  -x * 10 + 10,
                ), // Sombra se move oposta à luz
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Brilho especular (Glare)
              Positioned(
                left: -x * 50,
                top: -y * 50,
                child: Container(
                  width: 260,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                      center: Alignment(-y, -x), // O brilho segue o mouse
                    ),
                  ),
                ),
              ),
              // Conteúdo
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// COMPONENTE 13: DESKTOP EXPANSION PANEL
// ============================================================================
class DesktopExpansionPanel extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool initiallyExpanded;

  const DesktopExpansionPanel({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.initiallyExpanded = false,
  });

  @override
  State<DesktopExpansionPanel> createState() => _DesktopExpansionPanelState();
}

class _DesktopExpansionPanelState extends State<DesktopExpansionPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _rotation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeOutCubic));
    _rotation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _isExpanded = widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(widget.icon, color: theme.primaryColor, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: _rotation,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Área Expansível
        AnimatedBuilder(
          animation: _controller.view,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _heightFactor.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(60, 0, 24, 24),
            // Alinhado com o texto do título
            child: Text(
              widget.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontFeatures: [
                  const FontFeature.tabularFigures(),
                ], // Números alinhados
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// COMPONENTE 14: PULSE BADGE (Notificação)
// ============================================================================
class DesktopPulseBadge extends StatefulWidget {
  final Color color;
  final IconData icon;

  const DesktopPulseBadge({super.key, required this.color, required this.icon});

  @override
  State<DesktopPulseBadge> createState() => _DesktopPulseBadgeState();
}

class _DesktopPulseBadgeState extends State<DesktopPulseBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Círculo que expande e desaparece
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(
                  1.0 - _controller.value,
                ), // Fade out
              ),
              transform: Matrix4.identity()
                ..scale(_controller.value * 1.5), // Scale up
            );
          },
        ),
        // Ícone Fixo
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

// ============================================================================
// SEÇÃO 7: BOTÕES ANIMADOS
// ============================================================================
class _ButtonAnimationsSection extends StatelessWidget {
  final ThemeData theme;

  const _ButtonAnimationsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1. Botão com Efeito 'Shine' (Brilho)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DesktopShineButton(
              label: "Começar Agora",
              color: theme.primaryColor,
              onPressed: () {},
            ),
            const SizedBox(width: 24),
            const DesktopShineButton(
              label: "Oferta Especial",
              color: Colors.purple,
              isInfinite: true, // Brilha o tempo todo
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "2. Morphing Loading (Transformação)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DesktopLoadingButton(
              label: "Salvar Dados",
              color: Colors.blue,
              icon: Icons.save,
            ),
            const SizedBox(width: 24),
            DesktopLoadingButton(
              label: "Enviar Email",
              color: Colors.green,
              icon: Icons.send,
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "3. Slide Icon (Hover Reveal)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DesktopSlideButton(
              label: "Próxima Etapa",
              icon: Icons.arrow_forward,
              color: theme.colorScheme.onSurface,
              bgColor: theme.colorScheme.surface,
            ),
            const SizedBox(width: 24),
            const DesktopSlideButton(
              label: "Deletar",
              icon: Icons.delete,
              color: Colors.white,
              bgColor: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "4. 3D Push (Efeito Físico)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Desktop3DButton(
              label: "Click Me!",
              color: Colors.indigo,
              onPressed: () {},
            ),
            const SizedBox(width: 32),
            Desktop3DButton(
              label: "Download",
              color: Colors.orange,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// COMPONENTE 15: DESKTOP SHINE BUTTON
// ============================================================================
class DesktopShineButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isInfinite;

  const DesktopShineButton({
    super.key,
    required this.label,
    required this.color,
    this.onPressed,
    this.isInfinite = false,
  });

  @override
  State<DesktopShineButton> createState() => _DesktopShineButtonState();
}

class _DesktopShineButtonState extends State<DesktopShineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isInfinite) {
      _controller.repeat(period: const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.isInfinite) _controller.forward(from: 0.0);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Texto Centralizado
              Center(
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              // Efeito de Brilho (Shine)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      widthFactor: 0.2, // Largura do brilho
                      alignment: AlignmentGeometry.lerp(
                        const Alignment(-2.0, 0),
                        const Alignment(2.0, 0),
                        _controller.value,
                      )!,
                      child: Container(
                        // CORREÇÃO AQUI: O transform fica no Container, não no decoration
                        transform: Matrix4.skewX(-0.3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
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
    );
  }
}

// ============================================================================
// COMPONENTE 16: DESKTOP LOADING BUTTON (MORPH)
// ============================================================================
class DesktopLoadingButton extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;

  const DesktopLoadingButton({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  State<DesktopLoadingButton> createState() => _DesktopLoadingButtonState();
}

class _DesktopLoadingButtonState extends State<DesktopLoadingButton> {
  bool _isLoading = false;

  void _toggleLoading() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    // Simula uma operação
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLoading,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: _isLoading ? 50 : 180,
        // Encolhe para virar círculo
        height: 50,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(_isLoading ? 25 : 8),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
      ),
    );
  }
}

// ============================================================================
// COMPONENTE 17: DESKTOP SLIDE ICON BUTTON
// ============================================================================
class DesktopSlideButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const DesktopSlideButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  State<DesktopSlideButton> createState() => _DesktopSlideButtonState();
}

class _DesktopSlideButtonState extends State<DesktopSlideButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        width: 160,
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Texto que desliza
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: _isHovering ? -20 : 0,
                // Vai para a esquerda
                right: _isHovering ? 20 : 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      color: widget.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // Ícone que entra
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                right: _isHovering ? 20 : -40,
                // Vem da direita
                top: 0,
                bottom: 0,
                child: Center(child: Icon(widget.icon, color: widget.color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// COMPONENTE 18: DESKTOP 3D PUSH BUTTON
// ============================================================================
class Desktop3DButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const Desktop3DButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<Desktop3DButton> createState() => _Desktop3DButtonState();
}

class _Desktop3DButtonState extends State<Desktop3DButton> {
  bool _isPressed = false;

  // Altura da "sombra" 3D
  final double _depth = 6.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        height: 50 + _depth, // Espaço total necessário
        width: 140,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Camada de Base (Sombra Sólida)
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Color.lerp(widget.color, Colors.black, 0.3),
                // Cor mais escura
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Camada de Topo (Móvel)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              bottom: _isPressed ? 0 : _depth,
              // Move para baixo ao clicar
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    // Highlight sutil no topo
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SEÇÃO 8: CORES & TIPOGRAFIA
// ============================================================================
class _ColorsTypographySection extends StatelessWidget {
  final ThemeData theme;

  const _ColorsTypographySection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Paleta Principal",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _ColorSwatch(
              color: theme.primaryColor,
              label: "Primary",
              hex: _colorToHex(theme.primaryColor),
            ),
            _ColorSwatch(
              color: theme.colorScheme.surface,
              label: "Surface",
              hex: _colorToHex(theme.colorScheme.surface),
              hasBorder: true,
            ),
            _ColorSwatch(
              color: theme.scaffoldBackgroundColor,
              label: "Background",
              hex: _colorToHex(theme.scaffoldBackgroundColor),
              hasBorder: true,
            ),
            _ColorSwatch(
              color: theme.colorScheme.secondary,
              label: "Secondary",
              hex: _colorToHex(theme.colorScheme.secondary),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "Cores Semânticas (Status)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _ColorSwatch(color: Colors.green, label: "Success", hex: "#4CAF50"),
            _ColorSwatch(
              color: theme.colorScheme.error,
              label: "Error",
              hex: _colorToHex(theme.colorScheme.error),
            ),
            _ColorSwatch(
              color: Colors.orange,
              label: "Warning",
              hex: "#FF9800",
            ),
            _ColorSwatch(color: Colors.blue, label: "Info", hex: "#2196F3"),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "Tipografia (Hierarquia)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Display Large",
                style: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Heading 1 (Titles)",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Heading 2 (Subtitles)",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor.withOpacity(0.2)),
              const SizedBox(height: 16),
              Text(
                "Body Text Large. Usado para introduções ou textos de destaque. A leitura deve ser fluida e confortável.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Body Text Default. O tamanho padrão para parágrafos longos, tabelas e conteúdos gerais. Deve ter bom contraste.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Caption / Small Text. Usado para legendas, datas e metadados.",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

// Widget Auxiliar de Amostra de Cor
// Widget Auxiliar de Amostra de Cor
class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;
  final String hex;
  final bool hasBorder;

  const _ColorSwatch({
    required this.color,
    required this.label,
    required this.hex,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Calcula a luminância para saber se o texto deve ser preto ou branco
    final isLightContent = color.computeLuminance() > 0.5;

    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: hasBorder
            ? Border.all(color: theme.dividerColor.withOpacity(0.2))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 12,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isLightContent
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isLightContent
                    ? Colors.black.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                hex,
                // CORREÇÃO AQUI: Use robotoMono ou jetBrainsMono
                style: GoogleFonts.robotoMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isLightContent ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SEÇÃO 9: FLUXOS & ESTADOS (Wizards, Timelines, Empty)
// ============================================================================
class _FlowsAndStatesSection extends StatelessWidget {
  final ThemeData theme;

  const _FlowsAndStatesSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Passo a Passo (Stepper Wizard)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: const DesktopStepper(
            steps: ["Conta", "Perfil", "Plano", "Confirmação"],
            currentStep: 2, // Índice 2 = "Plano"
          ),
        ),
        const SizedBox(height: 40),
        Text(
          "Linha do Tempo (Audit Log)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const DesktopTimeline(
          events: [
            TimelineEvent(
              title: "Pedido Criado",
              description: "O pedido #8492 foi iniciado via Web.",
              time: "10:00",
              isActive: true,
            ),
            TimelineEvent(
              title: "Pagamento Aprovado",
              description: "Cartão final 4242.",
              time: "10:05",
              isActive: true,
            ),
            TimelineEvent(
              title: "Em Separação",
              description: "Armazém SP-01.",
              time: "11:30",
              isActive: true,
            ),
            TimelineEvent(
              title: "Enviado",
              description: "Aguardando transportadora.",
              time: "---",
              isActive: false,
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "Estado Vazio (Empty State)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        DesktopEmptyState(
          title: "Nenhum arquivo encontrado",
          subtitle:
              "Tente ajustar seus filtros ou faça upload de um novo arquivo.",
          icon: Icons.folder_open_rounded,
          actionLabel: "Fazer Upload",
          onAction: () {},
        ),
        const SizedBox(height: 40),
        Text(
          "Tag Input (Filtros)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const DesktopTagInput(initialTags: ["Flutter", "Dart", "UI Design"]),
      ],
    );
  }
}

// ============================================================================
// COMPONENTE 19: DESKTOP STEPPER
// ============================================================================
class DesktopStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const DesktopStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final inactive = theme.disabledColor.withOpacity(0.3);

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        final isLast = index == steps.length - 1;

        Color color = isCompleted ? primary : (isActive ? primary : inactive);
        Color textColor = isActive || isCompleted
            ? theme.colorScheme.onSurface
            : theme.disabledColor;

        return Expanded(
          child: Row(
            children: [
              // Círculo com Número ou Check
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? primary
                      : (isActive
                          ? theme.colorScheme.surface
                          : Colors.transparent),
                  border: Border.all(color: color, width: 2),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : Text(
                          "${index + 1}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: isActive ? primary : inactive,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Texto
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "PASSO ${index + 1}",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Linha Conectora
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? primary.withOpacity(0.3)
                        : inactive.withOpacity(0.2),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// COMPONENTE 20: DESKTOP TIMELINE (VERTICAL)
// ============================================================================
class TimelineEvent {
  final String title;
  final String description;
  final String time;
  final bool isActive;

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.time,
    required this.isActive,
  });
}

class DesktopTimeline extends StatelessWidget {
  final List<TimelineEvent> events;

  const DesktopTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        final isLast = index == events.length - 1;
        final color = event.isActive
            ? theme.primaryColor
            : theme.disabledColor.withOpacity(0.3);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna da Esquerda (Tempo)
              SizedBox(
                width: 60,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    event.time,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Coluna do Meio (Linha e Bolinha)
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: event.isActive ? color : Colors.transparent,
                      border: Border.all(color: color, width: 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: theme.dividerColor.withOpacity(0.1),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Coluna da Direita (Conteúdo)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: event.isActive
                              ? theme.colorScheme.onSurface
                              : theme.disabledColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(
                            event.isActive ? 0.6 : 0.3,
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
      }).toList(),
    );
  }
}

// ============================================================================
// COMPONENTE 21: DESKTOP EMPTY STATE
// ============================================================================
class DesktopEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DesktopEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Background do card
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          // Pattern de fundo sutil (opcional)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              DesktopButton(
                label: actionLabel!,
                onPressed: onAction ?? () {},
                color: theme.primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COMPONENTE 22: DESKTOP TAG INPUT (Visual)
// ============================================================================
class DesktopTagInput extends StatefulWidget {
  final List<String> initialTags;

  const DesktopTagInput({super.key, this.initialTags = const []});

  @override
  State<DesktopTagInput> createState() => _DesktopTagInputState();
}

class _DesktopTagInputState extends State<DesktopTagInput> {
  late List<String> tags;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    tags = List.from(widget.initialTags);
  }

  void _addTag(String val) {
    if (val.isNotEmpty && !tags.contains(val)) {
      setState(() {
        tags.add(val);
        _controller.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...tags.map(
            (tag) => Container(
              padding: const EdgeInsets.only(
                left: 12,
                right: 4,
                top: 4,
                bottom: 4,
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _removeTag(tag),
                    borderRadius: BorderRadius.circular(4),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Input Invisível
          SizedBox(
            width: 120,
            child: TextField(
              controller: _controller,
              onSubmitted: _addTag,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Adicionar tag...",
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SEÇÃO 10: INTERFACE AVANÇADA (Tree, SideSheet, Tooltips)
// ============================================================================
class _AdvancedUISection extends StatelessWidget {
  final ThemeData theme;

  const _AdvancedUISection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tree View (Navegação Hierárquica)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Column(
            children: [
              DesktopTreeItem(
                label: "Documentos",
                icon: Icons.folder,
                children: [
                  DesktopTreeItem(
                    label: "Projetos",
                    icon: Icons.folder_open,
                    children: [
                      DesktopTreeItem(
                        label: "Dashboard.dart",
                        icon: Icons.code,
                      ),
                      DesktopTreeItem(label: "Styles.dart", icon: Icons.code),
                    ],
                  ),
                  DesktopTreeItem(
                    label: "Relatório.pdf",
                    icon: Icons.picture_as_pdf,
                  ),
                ],
              ),
              DesktopTreeItem(
                label: "Imagens",
                icon: Icons.image,
                children: [
                  DesktopTreeItem(
                    label: "Logo.png",
                    icon: Icons.image_outlined,
                  ),
                  DesktopTreeItem(
                    label: "Banner.jpg",
                    icon: Icons.image_outlined,
                  ),
                ],
              ),
              DesktopTreeItem(label: "Configurações", icon: Icons.settings),
            ],
          ),
        ),

        const SizedBox(height: 40),

        Text(
          "Rich Tooltips (Com Atalhos)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DesktopRichTooltip(
              message: "Salvar alterações no banco de dados.",
              shortcut: "Ctrl + S",
              child: DesktopButton(
                label: "Salvar",
                onPressed: () {},
                color: Colors.blue,
                icon: Icons.save,
              ),
            ),
            const SizedBox(width: 24),
            DesktopRichTooltip(
              message: "Remover este item permanentemente.",
              shortcut: "Del",
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // ... dentro de _AdvancedUISection ...
        Text(
          "Side Sheet (Painel Lateral Avançado)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DesktopButton(
              label: "Ver Detalhes do Pedido",
              icon: Icons.list_alt,
              color: theme.primaryColor,
              onPressed: () {
                showDesktopSideSheet(
                  context: context,
                  title: "Detalhes do Pedido #8492",
                  // Conteúdo com rolagem independente
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        theme,
                        "Cliente",
                        "Empresa Tech Solutions Ltda",
                      ),
                      _buildDetailRow(
                        theme,
                        "Email",
                        "contato@techsolutions.com",
                      ),
                      _buildDetailRow(theme, "Data", "03 Dez, 2025 - 14:30"),
                      _buildDetailRow(theme, "Status", "Processando Pagamento"),
                      const SizedBox(height: 24),
                      Text(
                        "Itens do Pedido",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 100,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        child: const Center(child: Text("Lista de itens...")),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Histórico",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Exemplo de conteúdo longo para testar scroll
                      Text(
                        "O pedido foi criado automaticamente via API.\nO pagamento foi tentado 3 vezes.\nO sistema de fraude aprovou a transação.\nAguardando separação no estoque.",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  // Ações do Rodapé
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Fechar"),
                    ),
                    const SizedBox(width: 8),
                    DesktopButton(
                      label: "Emitir Nota Fiscal",
                      onPressed: () => Navigator.pop(context),
                      color: theme.primaryColor,
                    ),
                  ],
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 40),

        Text(
          "Toast Notifications (Estilo Desktop)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            DesktopButton(
              label: "Show Success",
              onPressed: () => _showToast(
                context,
                "Arquivo Salvo",
                "As alterações foram sincronizadas.",
                Colors.green,
                Icons.check_circle,
              ),
              color: Colors.green,
            ),
            const SizedBox(width: 16),
            DesktopButton(
              label: "Show Error",
              onPressed: () => _showToast(
                context,
                "Erro de Conexão",
                "Verifique sua internet e tente novamente.",
                Colors.red,
                Icons.wifi_off,
              ),
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  // Helper simples para simular Toast (Em prod use um OverlayEntry)
  void _showToast(
    BuildContext context,
    String title,
    String msg,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        width: 400,
        // Largura fixa estilo notificação
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2C)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      msg,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper para o exemplo do Side Sheet
Widget _buildDetailRow(ThemeData theme, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// COMPONENTE 23: DESKTOP TREE VIEW ITEM
// ============================================================================
class DesktopTreeItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<DesktopTreeItem>? children;

  const DesktopTreeItem({
    super.key,
    required this.label,
    required this.icon,
    this.children,
  });

  @override
  State<DesktopTreeItem> createState() => _DesktopTreeItemState();
}

class _DesktopTreeItemState extends State<DesktopTreeItem> {
  bool _isExpanded = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasChildren = widget.children != null && widget.children!.isNotEmpty;

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (hasChildren) setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isHovering
                    ? theme.colorScheme.onSurface.withOpacity(0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  // Seta de expansão (invisível se não tiver filhos para manter alinhamento)
                  SizedBox(
                    width: 20,
                    child: hasChildren
                        ? Icon(
                            _isExpanded
                                ? Icons.arrow_drop_down
                                : Icons.arrow_right,
                            size: 18,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.5,
                            ),
                          )
                        : null,
                  ),
                  Icon(
                    widget.icon,
                    size: 16,
                    color: _isExpanded
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          _isExpanded ? FontWeight.w600 : FontWeight.w400,
                      color: _isExpanded
                          ? theme.primaryColor
                          : theme.colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasChildren && _isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 20), // Indentação
            child: Column(children: widget.children!),
          ),
      ],
    );
  }
}

// ============================================================================
// COMPONENTE 24: DESKTOP RICH TOOLTIP
// ============================================================================
class DesktopRichTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final String? shortcut;

  const DesktopRichTooltip({
    super.key,
    required this.child,
    required this.message,
    this.shortcut,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos o widget Tooltip nativo mas customizamos o decoration e text style
    // Para algo mais complexo, usaríamos OverlayEntry.
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF202020), // Fundo escuro estilo IDE
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
      waitDuration: const Duration(milliseconds: 500),
      // Delay desktop padrão
      child: child,
      // O Tooltip nativo não suporta RichText facilmente na propriedade message.
      // Se precisar do atalho visual, o ideal é criar um Overlay customizado.
      // Mas o Tooltip nativo é o mais acessível e rápido.
    );
  }
}
// ============================================================================
// COMPONENTE MELHORADO: DESKTOP SIDE SHEET
// ============================================================================

/// Função para chamar o Side Sheet
void showDesktopSideSheet({
  required BuildContext context,
  required String title,
  required Widget body,
  List<Widget>? actions,
  double width = 450,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    // Permite fechar clicando fora
    barrierLabel: "Fechar",
    barrierColor: Colors.black.withOpacity(0.3),
    // Scrim escuro
    transitionDuration: const Duration(milliseconds: 400),
    // Tempo da animação
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight, // Fixa na direita
        child: _SideSheetWidget(
          title: title,
          body: body,
          actions: actions,
          width: width,
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Animação de deslize da direita (Offset 1.0 -> 0.0)
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart, // Curva super suave (estilo macOS)
          reverseCurve: Curves.easeInQuad,
        ),
      );

      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

class _SideSheetWidget extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final double width;

  const _SideSheetWidget({
    required this.title,
    required this.body,
    this.actions,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores translúcidas para o efeito de vidro
    final backgroundColor = theme.colorScheme.surface.withOpacity(
      isDark ? 0.90 : 0.95,
    );
    final borderColor = theme.dividerColor.withOpacity(0.1);

    return Material(
      color: Colors.transparent,
      // ClipRect impede que o blur vaze para fora das bordas arredondadas (se houver)
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // O efeito "Vidro"
          child: Container(
            width: width,
            height: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(left: BorderSide(color: borderColor, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 50,
                  spreadRadius: -10,
                  offset: const Offset(-20, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER (Mais limpo e moderno)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 28, 24, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Botão Fechar Circular
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.05,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: borderColor),

                // 2. BODY (Com Scrollbar visível)
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true, // Importante para Desktop
                    thickness: 6,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(32),
                      child: body,
                    ),
                  ),
                ),

                // 3. FOOTER (Com sombra invertida para profundidade)
                if (actions != null && actions!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      // Fundo sólido para cobrir o scroll
                      border: Border(top: BorderSide(color: borderColor)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, -5), // Sombra para cima
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!.map((widget) {
                        // Adiciona espaçamento entre os botões automaticamente
                        return Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: widget,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NOVO: DESKTOP IMAGE CARD (Estilo Notícia/Produto)
// ============================================================================
class DesktopImageCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String tag;
  final double width;
  final VoidCallback onTap;

  const DesktopImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.tag,
    required this.width,
    required this.onTap,
  });

  @override
  State<DesktopImageCard> createState() => _DesktopImageCardState();
}

class _DesktopImageCardState extends State<DesktopImageCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          transform: Matrix4.translationValues(0, _isHovering ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovering
                  ? theme.primaryColor.withOpacity(0.3)
                  : theme.dividerColor.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovering ? 0.1 : 0.05),
                blurRadius: _isHovering ? 20 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem de Capa
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.network(widget.imageUrl, fit: BoxFit.cover),
                ),
              ),
              // Conteúdo
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.tag.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NOVO: DESKTOP ACTION CARD (Com botões no rodapé)
// ============================================================================
class DesktopActionCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final double width;

  const DesktopActionCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: theme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
          // Área de Ações
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(
                    secondaryActionLabel,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onPrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    primaryActionLabel,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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

// ============================================================================
// NOVO: DESKTOP PROFILE CARD (Avatar + Stats)
// ============================================================================
class DesktopProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final Map<String, String> stats;
  final double width;

  const DesktopProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.stats,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            role,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.entries.map((entry) {
                return Column(
                  children: [
                    Text(
                      entry.value,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      entry.key,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Ver Perfil",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SEÇÃO 11: DATA & HORA (Date Pickers, Time Inputs)
// ============================================================================
class _DatePickersSection extends StatelessWidget {
  final ThemeData theme;
  final BuildContext context;

  const _DatePickersSection({required this.theme, required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Inputs de Data (Triggers)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            // Input Simples
            SizedBox(
              width: 250,
              child: DesktopDatePickerInput(
                label: "Data de Início",
                hint: "DD/MM/AAAA",
                onDateSelected: (date) {},
              ),
            ),
            // Input com Ícone diferente
            SizedBox(
              width: 250,
              child: DesktopDatePickerInput(
                label: "Prazo Final",
                hint: "Selecione...",
                icon: Icons.event_available,
                onDateSelected: (date) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "Seleção de Período (Range)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const DesktopRangeSelector(),
        const SizedBox(height: 40),
        Text(
          "Input de Hora (Digital)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const DesktopTimeInput(label: "Horário de Início"),
            const SizedBox(width: 24),
            // Exemplo desabilitado ou readonly visualmente
            Opacity(
              opacity: 0.6,
              child: const DesktopTimeInput(
                label: "Fim (Automático)",
                initialHour: "18",
                initialMinute: "00",
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          "Mini Calendário (Widget)",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DesktopMiniCalendar(),
            SizedBox(width: 40),
            // Versão Compacta/Evento
            DesktopEventCard(
              day: "12",
              month: "AGO",
              title: "Reunião de Board",
              time: "14:00 - 16:00",
              participants: [
                "",
                "",
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// COMPONENTE 25: DESKTOP DATE PICKER INPUT
// ============================================================================
class DesktopDatePickerInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Function(DateTime) onDateSelected;

  const DesktopDatePickerInput({
    super.key,
    required this.label,
    this.hint = "Selecione uma data",
    this.icon = Icons.calendar_today_rounded,
    required this.onDateSelected,
  });

  @override
  State<DesktopDatePickerInput> createState() => _DesktopDatePickerInputState();
}

class _DesktopDatePickerInputState extends State<DesktopDatePickerInput> {
  DateTime? _selectedDate;
  bool _isHovering = false;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Customizando o tema do DatePicker nativo para combinar com o app
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: Theme.of(context).colorScheme.surface,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Formatação simples da data (DD/MM/AAAA)
    String dateText = widget.hint;
    if (_selectedDate != null) {
      dateText =
          "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _pickDate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isHovering
                      ? theme.primaryColor
                      : theme.dividerColor.withOpacity(0.3),
                  width: _isHovering ? 1.5 : 1,
                ),
                boxShadow: _isHovering
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateText,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _selectedDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  Icon(
                    widget.icon,
                    size: 18,
                    color: _isHovering
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// COMPONENTE 26: DESKTOP RANGE SELECTOR
// ============================================================================
class DesktopRangeSelector extends StatefulWidget {
  const DesktopRangeSelector({super.key});

  @override
  State<DesktopRangeSelector> createState() => _DesktopRangeSelectorState();
}

class _DesktopRangeSelectorState extends State<DesktopRangeSelector> {
  int _selectedIndex = 0;
  final List<String> _options = [
    "Hoje",
    "Ontem",
    "7 Dias",
    "30 Dias",
    "Personalizado",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Wrap(
        children: List.generate(_options.length, (index) {
          final isSelected = _selectedIndex == index;
          return InkWell(
            onTap: () => setState(() => _selectedIndex = index),
            borderRadius: BorderRadius.circular(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _options[index],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================================
// COMPONENTE 27: DESKTOP TIME INPUT (DIGITAL)
// ============================================================================
class DesktopTimeInput extends StatelessWidget {
  final String label;
  final String initialHour;
  final String initialMinute;

  const DesktopTimeInput({
    super.key,
    required this.label,
    this.initialHour = "09",
    this.initialMinute = "30",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _TimeField(value: initialHour, theme: theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                ":",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.disabledColor,
                ),
              ),
            ),
            _TimeField(value: initialMinute, theme: theme),
            const SizedBox(width: 8),
            // AM/PM Toggle (Opcional, estilo visual)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "AM",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  final String value;
  final ThemeData theme;

  const _TimeField({required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Text(
        value,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

// ============================================================================
// COMPONENTE 28: DESKTOP MINI CALENDAR (Visual Widget)
// ============================================================================
class DesktopMiniCalendar extends StatelessWidget {
  const DesktopMiniCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Agosto 2025",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: theme.disabledColor,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Days Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["D", "S", "T", "Q", "Q", "S", "S"]
                .map(
                  (d) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.disabledColor,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Calendar Grid (Simulado)
          Wrap(
            spacing: 8, // Ajuste para alinhar
            runSpacing: 8,
            children: List.generate(31 + 4, (index) {
              // +4 offset dias vazios
              if (index < 4)
                return const SizedBox(width: 32, height: 32); // Offset

              final day = index - 3;
              final isToday = day == 12;
              final isSelected = day == 14;
              final isPast = day < 12;

              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor
                      : (isToday
                          ? theme.primaryColor.withOpacity(0.1)
                          : Colors.transparent),
                  shape: BoxShape.circle,
                  border:
                      isToday ? Border.all(color: theme.primaryColor) : null,
                ),
                child: Center(
                  child: Text(
                    "$day",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: (isSelected || isToday)
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isPast
                              ? theme.disabledColor
                              : theme.colorScheme.onSurface),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPONENTE 29: DESKTOP EVENT CARD
// ============================================================================
class DesktopEventCard extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String time;
  final List<String> participants;

  const DesktopEventCard({
    super.key,
    required this.day,
    required this.month,
    required this.title,
    required this.time,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Data
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                Text(
                  month,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.disabledColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Avatares
                Row(
                  children: participants
                      .map(
                        (url) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: theme.disabledColor,
                            backgroundImage: NetworkImage(url),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
