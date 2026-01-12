import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../core/widgets/custom_sliver_app_bar.dart';
import 'package:plataforma_pnsa/src/core/constants/app_constants.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

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
            title: 'Sobre',
            subtitle: 'Informações da versão e desenvolvedor',
            actions: [],
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 120 : (isTablet ? 60 : 24),
              vertical: 32,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 800 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      // App Logo & Version
                      _buildAppHeader(theme, primaryColor, isDark),

                      const SizedBox(height: 48),

                      // Description
                      Text(
                        'Este aplicativo foi desenvolvido para auxiliar na gestão da ${AppConstants.parishName}, facilitando o controle de fiéis, dízimos e administração dos acessos ao sistema por diferentes perfis.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Info Grid
                      _buildInfoGrid(
                        theme,
                        primaryColor,
                        isDark,
                        cardColor,
                        isDesktop,
                      ),

                      const SizedBox(height: 48),

                      // Legal Links
                      _buildLegalSection(
                        theme,
                        primaryColor,
                        isDark,
                        cardColor,
                      ),

                      const SizedBox(height: 32),

                      // Copyright
                      Text(
                        '${AppConstants.copyright}. Todos os direitos reservados.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),

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

  Widget _buildAppHeader(ThemeData theme, Color primaryColor, bool isDark) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Sistema ${AppConstants.parishName}',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Sistema de Gestão Paroquial',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
    bool isDesktop,
  ) {
    final items = [
      {
        'label': 'Paróquia',
        'value': AppConstants.parishName,
        'icon': Icons.church_outlined,
      },
      {
        'label': 'Localização',
        'value': 'Iporá, GO',
        'icon': Icons.location_city_outlined,
      },
      {
        'label': 'Endereço',
        'value': AppConstants.parishAddress,
        'icon': Icons.location_on_outlined,
      },
      {
        'label': 'Contato',
        'value': AppConstants.parishPhone,
        'icon': Icons.phone_outlined,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 2 : 1;
        final spacing = 16.0;
        final width =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: _buildInfoCard(
                theme,
                primaryColor,
                isDark,
                cardColor,
                item['icon'] as IconData,
                item['label'] as String,
                item['value'] as String,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(
    ThemeData theme,
    Color primaryColor,
    bool isDark,
    Color cardColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildLegalTile(theme, 'Termos de Uso', isDark),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
          _buildLegalTile(theme, 'Política de Privacidade', isDark),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
          _buildLegalTile(theme, 'Licenças de Terceiros', isDark),
        ],
      ),
    );
  }

  Widget _buildLegalTile(ThemeData theme, String title, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
