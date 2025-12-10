import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../core/widgets/custom_sliver_app_bar.dart';

class ThemeSettingsView extends StatelessWidget {
  ThemeSettingsView({super.key});

  // Reactive variables
  final RxBool isDarkMode = Get.isDarkMode.obs;
  final RxBool isSystemMode =
      (Get.theme == ThemeData.light() && Get.isDarkMode).obs;

  // Function to change theme
  void _changeTheme(ThemeMode mode) {
    Get.changeThemeMode(mode);

    // Atualiza estados locais para feedback visual imediato
    isDarkMode.value = mode == ThemeMode.dark ||
        (mode == ThemeMode.system && Get.isPlatformDarkMode);
    isSystemMode.value = mode == ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final isDesktop = size.width >= 1000;

    // === AJUSTE DE COR AQUI ===
    // Antes era 0xFF141414 (Muito escuro)
    // Agora é 0xFF202020 (Padrão Windows 11 Dark / VS Code)
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF202020)
        : const Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(
            title: 'Aparência',
            subtitle: 'Personalize a experiência visual do aplicativo',
            backgroundColor: bgColor.withOpacity(0.8), // Ajuste para combinar com o fundo
            actions: [],
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 0 : 24,
              vertical: 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho da Seção
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24, left: 8),
                        child: Text(
                          'Tema do Aplicativo',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),

                      // GRID DE SELEÇÃO (VISUAL PREVIEW)
                      Obx(() {
                        final dark = isDarkMode.value;
                        final system = isSystemMode.value;

                        final lightSelected = !dark && !system;
                        final darkSelected = dark && !system;
                        final systemSelected = system;

                        // Layout Responsivo
                        if (isDesktop) {
                          return Row(
                            children: [
                              Expanded(
                                  child: _ThemeOptionCard(
                                    label: "Claro",
                                    mode: ThemeMode.light,
                                    isSelected: lightSelected,
                                    onTap: () => _changeTheme(ThemeMode.light),
                                    theme: theme,
                                  )),
                              const SizedBox(width: 20),
                              Expanded(
                                  child: _ThemeOptionCard(
                                    label: "Escuro",
                                    mode: ThemeMode.dark,
                                    isSelected: darkSelected,
                                    onTap: () => _changeTheme(ThemeMode.dark),
                                    theme: theme,
                                  )),
                              const SizedBox(width: 20),
                              Expanded(
                                  child: _ThemeOptionCard(
                                    label: "Automático",
                                    mode: ThemeMode.system,
                                    isSelected: systemSelected,
                                    onTap: () => _changeTheme(ThemeMode.system),
                                    theme: theme,
                                  )),
                            ],
                          );
                        } else {
                          // Mobile Layout
                          return Column(
                            children: [
                              _ThemeOptionCard(
                                label: "Claro",
                                mode: ThemeMode.light,
                                isSelected: lightSelected,
                                onTap: () => _changeTheme(ThemeMode.light),
                                theme: theme,
                              ),
                              const SizedBox(height: 16),
                              _ThemeOptionCard(
                                label: "Escuro",
                                mode: ThemeMode.dark,
                                isSelected: darkSelected,
                                onTap: () => _changeTheme(ThemeMode.dark),
                                theme: theme,
                              ),
                              const SizedBox(height: 16),
                              _ThemeOptionCard(
                                label: "Automático",
                                mode: ThemeMode.system,
                                isSelected: systemSelected,
                                onTap: () => _changeTheme(ThemeMode.system),
                                theme: theme,
                              ),
                            ],
                          );
                        }
                      }),

                      const SizedBox(height: 48),

                      // INFO SECTION
                      _buildInfoSection(theme),

                      const SizedBox(height: 100), // Espaço final
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    // Ajuste da cor do card de info para não sumir no novo fundo
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        // Borda sutil para separar do fundo
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_outlined,
              color: theme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sincronização com o Sistema',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ao selecionar "Automático", o aplicativo seguirá as configurações de aparência do seu Windows ou macOS.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// =============================================================================
// COMPONENTE: CARTÃO DE OPÇÃO DE TEMA (COM PREVIEW VISUAL)
// =============================================================================
class _ThemeOptionCard extends StatefulWidget {
  final String label;
  final ThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ThemeOptionCard({
    required this.label,
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_ThemeOptionCard> createState() => _ThemeOptionCardState();
}

class _ThemeOptionCardState extends State<_ThemeOptionCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.primaryColor;

    // Borda: Se selecionado usa Primary, se Hover usa divider, senão transparente
    final borderColor = widget.isSelected
        ? primaryColor
        : (_isHovering ? widget.theme.dividerColor.withOpacity(0.5) : Colors.transparent);

    // Altura fixa para o card de preview
    const double previewHeight = 140;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            // 1. O PREVIEW VISUAL (A "Janela")
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: previewHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                // Fundo do preview transparente para ver o desenho interno
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor.withOpacity(widget.isSelected ? 1 : 0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildThemeSkeleton(widget.mode),
              ),
            ),

            const SizedBox(height: 12),

            // 2. O LABEL + RADIO BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Radio Button Customizado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isSelected
                          ? primaryColor
                          : widget.theme.colorScheme.onSurface.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: widget.isSelected ? 10 : 0,
                      height: widget.isSelected ? 10 : 0,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Constrói o "esqueleto" que simula a interface
  Widget _buildThemeSkeleton(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      // Split View (Metade Claro / Metade Escuro)
      return Row(
        children: [
          Expanded(child: _buildSkeletonUI(isDark: false)),
          Expanded(child: _buildSkeletonUI(isDark: true)),
        ],
      );
    }
    return _buildSkeletonUI(isDark: mode == ThemeMode.dark);
  }

  // Desenha a mini-interface
  Widget _buildSkeletonUI({required bool isDark}) {
    // Cores internas do preview (Ajustadas para ter contraste com o novo fundo)
    final bg = isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF5F5F5);
    final surface = isDark ? const Color(0xFF383838) : const Color(0xFFFFFFFF);

    final accent = widget.theme.primaryColor.withOpacity(isDark ? 0.7 : 0.8);
    final textLines = isDark ? Colors.white24 : Colors.black12;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Botão" primário
          Container(
            width: 40,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          // "Card" 1
          Container(
            height: 30,
            decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 2)
                ]),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                        color: textLines, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Container(height: 4, color: textLines)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // "Card" 2
          Container(
            height: 30,
            decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 2)
                ]),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                        color: textLines, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Container(height: 4, color: textLines)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}