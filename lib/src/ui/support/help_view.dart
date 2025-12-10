import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../routes/app_routes.dart';
import '../core/widgets/custom_sliver_app_bar.dart';


class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 768 && size.width < 1024;
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    // Fluent/Material 3 colors
    final surfaceColor =
        isDark ? const Color(0xFF1C1C1C) : const Color(0xFFFFFBFE);
    final cardColor = isDark ? const Color(0xFF2B2B2B) : Colors.white;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(
            title: 'Ajuda',
            subtitle: 'Como podemos ajudar você hoje?',
            actions: [],
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 120 : (isTablet ? 60 : 24),
              vertical: 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 900 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      _buildSearchBar(theme, primaryColor, isDark, cardColor),

                      const SizedBox(height: 48),

                      // Quick Access / Topics
                      Text(
                        'Tópicos Populares',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTopicsGrid(
                        theme,
                        primaryColor,
                        isDark,
                        cardColor,
                        isDesktop,
                      ),

                      const SizedBox(height: 48),

                      // Support Options
                      Text(
                        'Ainda precisa de ajuda?',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSupportOptions(
                        theme,
                        primaryColor,
                        isDark,
                        cardColor,
                        isDesktop,
                      ),

                      const SizedBox(height: 48),

                      // About Link
                      _buildAboutLink(theme, primaryColor, isDark, cardColor),

                      const SizedBox(height: 32),
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

  Widget _buildSearchBar(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28), // Pill shape for modern feel
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por dúvidas, erros ou tópicos...',
                hintStyle: GoogleFonts.inter(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.mic_none_rounded, color: primaryColor, size: 22),
            onPressed: () {},
            tooltip: 'Pesquisa por voz',
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsGrid(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
    bool isDesktop,
  ) {
    final topics = [
      {
        'icon': Icons.lock_outline_rounded,
        'title': 'Privacidade',
        'desc': 'Dados e segurança',
      },
      {
        'icon': Icons.notifications_none_rounded,
        'title': 'Notificações',
        'desc': 'Alertas e sons',
      },
      {
        'icon': Icons.payment_rounded,
        'title': 'Pagamentos',
        'desc': 'Faturas e planos',
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Conta',
        'desc': 'Perfil e acesso',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 4 : 2;
        final spacing = 16.0;
        final width =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              topics.map((topic) {
                return SizedBox(
                  width: width,
                  child: _buildTopicCard(
                    theme,
                    primaryColor,
                    isDark,
                    cardColor,
                    topic['icon'] as IconData,
                    topic['title'] as String,
                    topic['desc'] as String,
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildTopicCard(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
    IconData icon,
    String title,
    String desc,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  hoverColor: primaryColor.withOpacity(0.04),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: primaryColor, size: 26),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportOptions(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
    bool isDesktop,
  ) {
    return Flex(
      direction: isDesktop ? Axis.horizontal : Axis.vertical,
      children: [
        Expanded(
          flex: isDesktop ? 1 : 0,
          child: _buildSupportCard(
            theme,
            primaryColor,
            isDark,
            cardColor,
            Icons.chat_bubble_outline_rounded,
            'Chat em Tempo Real',
            'Fale com nossa equipe agora',
            () => Get.snackbar('Suporte', 'Iniciando chat...'),
          ),
        ),
        SizedBox(width: isDesktop ? 16 : 0, height: isDesktop ? 0 : 16),
        Expanded(
          flex: isDesktop ? 1 : 0,
          child: _buildSupportCard(
            theme,
            primaryColor,
            isDark,
            cardColor,
            Icons.mail_outline_rounded,
            'Enviar E-mail',
            'Resposta em até 24 horas',
            () => Get.snackbar('Email', 'Abrindo cliente de email...'),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCard(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          hoverColor: primaryColor.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutLink(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
  ) {
    return Center(
      child: TextButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.about),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        icon: Icon(
          Icons.info_outline_rounded,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        label: Text(
          'Sobre o aplicativo',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
