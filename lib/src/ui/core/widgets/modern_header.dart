import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../home/controlles/home_controller.dart';

class ModernHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon; // Ícone principal
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final IconData? actionIcon;
  final Color? actionColor;
  final bool showBackButton;

  const ModernHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.onActionPressed,
    this.actionLabel,
    this.actionIcon,
    this.actionColor,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor = theme.colorScheme.primary;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.crossAxisExtent < 600;
        final bool hasAction = onActionPressed != null;
        // Altura dinâmica baseada no conteúdo
        // Base: ~80-90px para Mobile, ~100px para Desktop
        // Se tiver ação: +50px
        final double baseHeight = isMobile ? 80 : 100;
        final double actionHeight = hasAction
            ? (isMobile ? 60 : 0)
            : 0; // No desktop action fica na row
        final double finalHeight = baseHeight + actionHeight;

        return SliverAppBar(
          backgroundColor: surfaceColor.withOpacity(isDark ? 0.8 : 0.95),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: false,
          floating: true,
          snap: true,
          // Botão de Menu no Mobile para abrir o Drawer
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Get.back(),
                  color: theme.colorScheme.onSurface,
                )
              : (isMobile
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
                      tooltip: 'Menu',
                    )
                  : null),
          automaticallyImplyLeading: false,
          toolbarHeight: finalHeight,
          titleSpacing: 0,
          title: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile
                  ? 0
                  : 24, // Reduzi padding esquerdo no mobile pois já tem o leading
              16,
              isMobile ? 16 : 24,
              16,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          // Icon removed on mobile per user request
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
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (onActionPressed != null) ...[
                        const SizedBox(height: 12),
                        _buildActionButton(isMobile: true),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      if (icon != null) ...[
                        _buildMainIcon(accentColor),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 28, // Texto grande padronizado
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (onActionPressed != null)
                        _buildActionButton(isMobile: false),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMainIcon(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withOpacity(0.8)],
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
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildActionButton({required bool isMobile}) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onActionPressed,
        icon: Icon(actionIcon ?? Icons.add_rounded, size: 20),
        label: Text(actionLabel ?? 'Adicionar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: actionColor ?? Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
