import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../core/widgets/modern_header.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            return _buildDesktopLayout(context, theme);
          } else {
            return _buildMobileLayout(context, theme);
          }
        },
      ),
    );
  }

  // ==========================================================
  // LAYOUT DESKTOP (2 Colunas)
  // ==========================================================
  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Modern App Bar
        const ModernHeader(
          title: 'Meu Perfil',
          subtitle: 'Gerencie suas informações pessoais',
          icon: Icons.person_rounded,
        ),

        // Content
        SliverPadding(
          padding:
              const EdgeInsets.only(left: 40, right: 40, top: 68, bottom: 40),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 380,
                      child: _ProfileCard(
                        controller: controller,
                        isDesktop: true,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildSettingsSection(context, isDesktop: true),
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

  // ==========================================================
  // LAYOUT MOBILE (Vertical)
  // ==========================================================
  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Mobile App Bar
        const ModernHeader(
          title: 'Meu Perfil',
          subtitle: 'Suas informações',
          icon: Icons.person_rounded,
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _ProfileCard(controller: controller, isDesktop: false),
                const SizedBox(height: 32),
                _buildSettingsSection(context, isDesktop: false),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required bool isDesktop,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? theme.colorScheme.primary : theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FluentSectionTitle(
          theme,
          "GERAL",
          Icons.settings_rounded,
          accentColor,
        ),
        const SizedBox(height: 12),
        _FluentSettingsGroup(
          children: [
            _DesktopHoverTile(
              icon: Icons.person_outline_rounded,
              title: 'Dados Pessoais',
              subtitle: 'Gerenciar meu cadastro',
              onTap: () {},
            ),
            _DesktopHoverTile(
              icon: Icons.lock_outline_rounded,
              title: 'Segurança',
              subtitle: 'Alterar minha senha',
              onTap: controller.changePassword,
            ),
          ],
        ),
        const SizedBox(height: 32),
        _FluentSectionTitle(
          theme,
          "PREFERÊNCIAS",
          Icons.tune_rounded,
          accentColor,
        ),
        const SizedBox(height: 12),
        _FluentSettingsGroup(
          children: [
            _DesktopHoverTile(
              icon: Icons.dark_mode_outlined,
              title: 'Aparência',
              subtitle: 'Tema do sistema',
              onTap: () => Get.toNamed(AppRoutes.theme_settings),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _FluentSectionTitle(
          theme,
          "SISTEMA",
          Icons.help_outline_rounded,
          accentColor,
        ),
        const SizedBox(height: 12),
        _FluentSettingsGroup(
          children: [
            _DesktopHoverTile(
              icon: Icons.help_outline_rounded,
              title: 'Ajuda e Suporte',
              onTap: () => Get.toNamed(AppRoutes.help),
            ),
            _DesktopHoverTile(
              icon: Icons.logout_rounded,
              title: 'Sair',
              onTap: controller.logout,
              isDestructive: true,
              showChevron: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _FluentSectionTitle(
    ThemeData theme,
    String title,
    IconData icon,
    Color accentColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: accentColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// COMPONENTES REUTILIZÁVEIS
// ==========================================================

class _ProfileCard extends StatelessWidget {
  final ProfileController controller;
  final bool isDesktop;

  const _ProfileCard({required this.controller, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final isDarkIcon = theme.brightness == Brightness.dark;
    final accentColor =
        isDarkIcon ? theme.colorScheme.primary : theme.primaryColor;

    return Obx(
      () => Container(
        padding: EdgeInsets.all(isDesktop ? 28 : 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar com gradiente
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surfaceColor,
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundImage: controller.avatarUrl.value.isNotEmpty
                      ? NetworkImage(controller.avatarUrl.value)
                      : null,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  child: controller.avatarUrl.value.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 56,
                          color: theme.colorScheme.onSurface,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              controller.name.value.isNotEmpty
                  ? controller.name.value
                  : 'Carregando...',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              controller.email.value.isNotEmpty
                  ? controller.email.value
                  : 'Email não disponível',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Informações do usuário (Reintegrado conforme pedido)
            if (controller.funcao.value.isNotEmpty ||
                controller.status.value.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 16 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.08),
                      accentColor.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                  border: Border.all(color: accentColor.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.funcao.value.isNotEmpty)
                      _buildInfoRow(
                        Icons.work_outline_rounded,
                        'Função',
                        controller.funcao.value,
                        theme,
                      ),
                    if (controller.status.value.isNotEmpty)
                      _buildInfoRow(
                        Icons.verified_user_outlined,
                        'Status',
                        controller.status.value,
                        theme,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.primary
                  : theme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
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

class _FluentSettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _FluentSettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          if (index != children.length - 1) {
            return Column(
              children: [
                widget,
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 64,
                  color: borderColor,
                ),
              ],
            );
          }
          return widget;
        }).toList(),
      ),
    );
  }
}

class _DesktopHoverTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;
  final bool showChevron;

  const _DesktopHoverTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
    this.trailing,
    this.showChevron = true,
  });

  @override
  State<_DesktopHoverTile> createState() => _DesktopHoverTileState();
}

class _DesktopHoverTileState extends State<_DesktopHoverTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color =
        widget.isDestructive ? Colors.redAccent : theme.colorScheme.onSurface;
    final iconColor = widget.isDestructive
        ? Colors.redAccent
        : (isDark ? theme.colorScheme.primary : theme.primaryColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _isHovering
              ? theme.colorScheme.onSurface.withOpacity(0.03)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: widget.isDestructive
                      ? LinearGradient(
                          colors: [
                            Colors.redAccent.withOpacity(0.15),
                            Colors.redAccent.withOpacity(0.08),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            theme.colorScheme.onSurface.withOpacity(0.1),
                            theme.colorScheme.onSurface.withOpacity(0.05),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: iconColor.withOpacity(widget.isDestructive ? 1 : 0.8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null)
                widget.trailing!
              else if (widget.showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
