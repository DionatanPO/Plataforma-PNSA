import 'dart:ui'; // Necessário para o ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double expandedHeight;
  final bool centerTitle;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.backgroundColor,
    this.expandedHeight = 120, // Altura padrão para Mobile
    this.centerTitle = false,
  });

  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 840;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final desktop = isDesktop(context);

    // Definições de Cores para Desktop (Estilo Windows 11 / macOS)
    // Usamos uma opacidade menor para permitir o efeito de blur
    final desktopSurface = isDark
        ? const Color(0xFF202020).withOpacity(0.75)
        : const Color(0xFFFFFFFF).withOpacity(0.85);

    // Cores Mobile (Material 3 padrão)
    final mobileSurface = backgroundColor ?? theme.colorScheme.surface;

    final onSurface = theme.colorScheme.onSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);

    // No desktop, a altura é fixa (padrão de sistemas operacionais)
    // No mobile, mantemos a expansão.
    final double currentExpandedHeight = desktop ? 70.0 : expandedHeight;
    final double currentToolbarHeight = desktop ? 70.0 : kToolbarHeight;

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      // Desktop: 0 de elevação (flat design). Mobile: elevação suave.
      elevation: desktop ? 0 : 2.0,
      scrolledUnderElevation: desktop ? 0 : 4.0,

      // Cor transparente no desktop para o blur funcionar, sólida no mobile
      backgroundColor: desktop ? Colors.transparent : mobileSurface,
      surfaceTintColor: desktop ? Colors.transparent : null,

      expandedHeight: currentExpandedHeight,
      toolbarHeight: currentToolbarHeight,

      // Ícone de voltar mais discreto no desktop
      leading: Navigator.canPop(context)
          ? Center(
        child: IconButton(
          // No desktop, botões costumam ser menores e mais discretos
          iconSize: desktop ? 20 : 24,
          splashRadius: desktop ? 20 : null,
          icon: Icon(
            // Seta mais fina ou arredondada dependendo do OS, aqui padronizamos
              Icons.arrow_back_rounded,
              color: onSurface.withOpacity(desktop ? 0.8 : 1.0)
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
      )
          : null,
      leadingWidth: desktop ? 60 : 56, // Mais espaçamento no desktop
      actions: actions?.map((widget) {
        // Ajuste fino para actions no desktop (opcional)
        return Padding(
          padding: EdgeInsets.only(right: desktop ? 8.0 : 0),
          child: widget,
        );
      }).toList(),

      flexibleSpace: ClipRect( // ClipRect impede o blur de vazar
        child: BackdropFilter(
          // O segredo do visual moderno: Blur no background (apenas desktop)
          filter: ImageFilter.blur(
              sigmaX: desktop ? 20.0 : 0.0,
              sigmaY: desktop ? 20.0 : 0.0
          ),
          child: Container(
            decoration: BoxDecoration(
              color: desktop ? desktopSurface : null, // Cor translúcida
              border: desktop
                  ? Border(bottom: BorderSide(color: borderColor, width: 1.0))
                  : null, // Borda 'hairline' moderna
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final top = constraints.biggest.height;

                // Lógica de colapso apenas para mobile
                final isCollapsed = !desktop && (top <= currentToolbarHeight + 30);

                // No desktop, o título não move. No mobile, ele sobe.
                final double titleLeftPadding = desktop
                    ? (Navigator.canPop(context) ? 60 : 24)
                    : (Navigator.canPop(context) ? 50 : 20); // Ajuste fino

                final double titleBottomPadding = desktop ? 14 : 16;

                return FlexibleSpaceBar(
                  centerTitle: false, // Desktop moderno alinha à esquerda
                  titlePadding: EdgeInsetsDirectional.only(
                    start: titleLeftPadding,
                    bottom: titleBottomPadding,
                    end: 24,
                  ),
                  expandedTitleScale: desktop ? 1.0 : 1.4, // Sem zoom no desktop
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: desktop ? FontWeight.w600 : FontWeight.w600,
                          color: onSurface,
                          // Fonte ligeiramente menor no desktop para elegância
                          fontSize: desktop ? 18 : 20,
                          letterSpacing: desktop ? -0.5 : 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Subtítulo
                      if (subtitle != null) ...[
                        if (desktop)
                        // Desktop: Subtítulo fixo, menor e mais transparente
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(
                              subtitle!,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: onSurface.withOpacity(0.6),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                        // Mobile: Animação de sumir ao colapsar
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isCollapsed ? 0.0 : 1.0,
                            child: isCollapsed
                                ? const SizedBox.shrink()
                                : Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                subtitle!,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: onSurface.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}