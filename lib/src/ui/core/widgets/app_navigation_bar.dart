import 'dart:ui'; // Necessário para o blur
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Mantido conforme seu import

class AdaptiveNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination>? destinations;
  final VoidCallback? onProfileTap;

  const AdaptiveNavigation({
    Key? key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.destinations,
    this.onProfileTap,
  }) : super(key: key);

  // ===== BREAKPOINTS =====
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 700;
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 700 && MediaQuery.of(context).size.width < 1100;
  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  // ===== NAV ITEMS PADRÃO =====
  static List<NavigationDestination> get defaultDestinations => [
    const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Painel Geral'),
    const NavigationDestination(icon: Icon(Icons.church_outlined), selectedIcon: Icon(Icons.church), label: 'Dizimistas'),
    const NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Contribuições'),
    const NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Relatórios'),
    const NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: 'Paróquia'),
    const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Configurações'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = destinations ?? defaultDestinations;

    if (isMobile(context)) {
      return _buildMobileNavigation(context, items, theme);
    } else {
      return _buildDesktopNavigation(context, items, theme);
    }
  }

  // =====================================================
  // ====================== MOBILE =======================
  // =====================================================
  Widget _buildMobileNavigation(BuildContext context, List<NavigationDestination> items, ThemeData theme) {
    // Vidro fosco para mobile também (estilo iOS)
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.8), // Translúcido
            border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
          ),
          child: NavigationBar(
            height: 65,
            backgroundColor: Colors.transparent, // Transparente para o blur funcionar
            elevation: 0,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: items,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ================= DESKTOP / TABLET ==================
  // =====================================================
  Widget _buildDesktopNavigation(BuildContext context, List<NavigationDestination> items, ThemeData theme) {
    final desktop = isDesktop(context);
    final width = desktop ? 260.0 : 80.0; // Largura fixa estilo Sidebar
    final isDark = theme.brightness == Brightness.dark;

    // Cores estilo Glassmorphism
    final glassColor = isDark
        ? const Color(0xFF1E1E1E).withOpacity(0.70)
        : const Color(0xFFF3F3F3).withOpacity(0.75);

    final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          decoration: BoxDecoration(
            color: glassColor,
            border: Border(right: BorderSide(color: borderColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header / Logo
              _buildHeader(context, theme, desktop),

              const SizedBox(height: 10),

              // Lista de Itens
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: desktop ? 12 : 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = index == currentIndex;

                    // Usamos um Widget customizado para controlar o Hover e estilo Windows
                    return _DesktopSidebarItem(
                      icon: isSelected ? item.selectedIcon ?? item.icon : item.icon,
                      label: item.label,
                      isSelected: isSelected,
                      isCollapsed: !desktop,
                      onTap: () => onDestinationSelected(index),
                      theme: theme,
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

  // =====================================================
  // ======================== HEADER =====================
  // =====================================================
  Widget _buildHeader(BuildContext context, ThemeData theme, bool isExpanded) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          isExpanded ? 20 : 0,
          30,
          isExpanded ? 20 : 0,
          20
      ),
      child: isExpanded
          ? Row(
        children: [
          _buildAppIcon(theme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paróquia NS Auxiliadora',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Sistema de Dízimo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : _buildAppIcon(theme),
    );
  }

  Widget _buildAppIcon(ThemeData theme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8), // Borda mais quadrada (Windows/Mac style)
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
      ),
      child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 20),
    );
  }


}

// ==============================================================================
// WIDGET AUXILIAR: ITEM DA SIDEBAR COM EFEITO DE HOVER (Estado Local para Hover)
// ==============================================================================
class _DesktopSidebarItem extends StatefulWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;
  final ThemeData theme;
  final Color? textColor;

  const _DesktopSidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
    required this.theme,
    this.textColor,
  });

  @override
  State<_DesktopSidebarItem> createState() => _DesktopSidebarItemState();
}

class _DesktopSidebarItemState extends State<_DesktopSidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;

    // Cores dinâmicas para estados
    final selectedBg = widget.theme.colorScheme.primary.withOpacity(0.12);
    final hoverBg = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04);
    final transparent = Colors.transparent;

    final bgColor = widget.isSelected
        ? selectedBg
        : (_isHovering ? hoverBg : transparent);

    final fgColor = widget.textColor ?? (widget.isSelected
        ? widget.theme.colorScheme.primary
        : widget.theme.colorScheme.onSurface.withOpacity(0.8));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: 44, // Altura padrão de itens de menu em desktop
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6), // Bordas levemente arredondadas (Windows 11)
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              // Ícone
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.isCollapsed ? 0 : 12),
                child: IconTheme(
                  data: IconThemeData(
                      size: 20,
                      color: fgColor
                  ),
                  child: widget.icon,
                ),
              ),

              // Texto (apenas se expandido)
              if (!widget.isCollapsed)
                Expanded(
                  child: Text(
                    widget.label,
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      color: fgColor,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Indicador de seleção sutil à esquerda (Opcional, estilo macOS)
              if (widget.isSelected && !widget.isCollapsed)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}