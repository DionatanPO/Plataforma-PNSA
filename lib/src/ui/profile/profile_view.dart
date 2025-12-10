import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Configuração de barra de status (mais relevante para mobile, mas ok manter)
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // No Desktop, geralmente não usamos AppBar padrão se tivermos Sidebar.
      // Se não tiver Sidebar, deixamos transparente ou usamos uma header customizada.
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
    return Scrollbar( // Desktop precisa de Scrollbar
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da Página (Estilo Windows Settings)
                Text(
                  'Meu Perfil',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coluna Esquerda: Cartão de Perfil Fixo
                    SizedBox(
                      width: 320,
                      child: _ProfileCard(controller: controller, isDesktop: true),
                    ),
                    const SizedBox(width: 32),

                    // Coluna Direita: Estatísticas e Configurações
                    Expanded(
                      child: Column(
                        children: [
                          _buildStatsSection(context, isDesktop: true),
                          const SizedBox(height: 32),
                          _buildSettingsSection(context, isDesktop: true),
                        ],
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

  // ==========================================================
  // LAYOUT MOBILE (Vertical)
  // ==========================================================
  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _ProfileCard(controller: controller, isDesktop: false),
          const SizedBox(height: 32),
          _buildStatsSection(context, isDesktop: false),
          const SizedBox(height: 32),
          _buildSettingsSection(context, isDesktop: false),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, {required bool isDesktop}) {
    final theme = Theme.of(context);

    // No Desktop, usamos Row ou Wrap expandido.
    // Os cards devem parecer "widgets" do sistema.
    final children = [
      _FluentStatCard(
        label: "Tarefas Concluídas",
        value: controller.tasksCompleted.value.toString(),
        icon: Icons.check_circle_outline_rounded,
        color: Colors.blueAccent,
        theme: theme,
      ),
      _FluentStatCard(
        label: "Projetos Ativos",
        value: controller.projectsActive.value.toString(),
        icon: Icons.folder_open_rounded,
        color: Colors.orangeAccent,
        theme: theme,
      ),
      if (isDesktop)
        _FluentStatCard(
          label: "Produtividade",
          value: "94%",
          icon: Icons.trending_up_rounded,
          color: Colors.greenAccent,
          theme: theme,
        ),
    ];

    if (isDesktop) {
      return Row(
        children: children.map((e) => Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: e,
        ))).toList(),
      );
    } else {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children,
      );
    }
  }

  Widget _buildSettingsSection(BuildContext context, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FluentSectionTitle(Theme.of(context), "GERAL"),
        _FluentSettingsGroup(
          children: [
            _DesktopHoverTile(
              icon: Icons.person_outline_rounded,
              title: 'Dados Pessoais',
              subtitle: 'Nome, bio e foto',
              onTap: () {

              },
            ),
            _DesktopHoverTile(
              icon: Icons.lock_outline_rounded,
              title: 'Segurança',
              subtitle: 'Senha e autenticação',
              onTap: controller.changePassword,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _FluentSectionTitle(Theme.of(context), "PREFERÊNCIAS"),
        _FluentSettingsGroup(
          children: [
            _DesktopHoverTile(
              icon: Icons.notifications_outlined,
              title: 'Notificações',
              // Desktop geralmente usa toggles diretos, mas manteremos o padrão por enquanto
              trailing: Switch(
                value: true,
                onChanged: (v) => controller.toggleNotifications(),
                activeColor: Theme.of(context).primaryColor,
              ),
              onTap: (){},
            ),
            _DesktopHoverTile(
              icon: Icons.dark_mode_outlined,
              title: 'Aparência',
              subtitle: 'Tema do sistema',
              onTap: () => Get.toNamed(AppRoutes.theme_settings),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _FluentSectionTitle(Theme.of(context), "SISTEMA"),
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

  Widget _FluentSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ==========================================================
// COMPONENTES REUTILIZÁVEIS E MODERNIZADOS
// ==========================================================

class _ProfileCard extends StatelessWidget {
  final ProfileController controller;
  final bool isDesktop;

  const _ProfileCard({required this.controller, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12), // Bordas menos arredondadas que mobile (16->12)
        border: Border.all(color: borderColor),
        boxShadow: isDesktop
            ? [] // Desktop geralmente é flat ou tem sombra muito sutil
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor.withOpacity(0.2), width: 1),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(controller.avatarUrl.value),
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.name.value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            controller.email.value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Botões de Ação
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0, // Flat design
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Editar Perfil"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                side: BorderSide(color: theme.dividerColor),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Compartilhar"),
            ),
          ),
        ],
      ),
    );
  }
}

class _FluentStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _FluentStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
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
    // No desktop moderno, as vezes não usamos o card "grouped" inteiro,
    // mas sim tiles individuais. Porém, o estilo "grouped" (iOS/macOS) ainda é muito elegante.
    // Vamos manter, mas com bordas mais sutis.
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          // Adiciona divisor entre os itens, exceto no último
          if (index != children.length - 1) {
            return Column(
              children: [
                widget,
                Divider(
                    height: 1,
                    thickness: 1,
                    indent: 60, // Indentação estilo iOS/macOS
                    color: theme.dividerColor.withOpacity(0.1)
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

// Widget com Hover State para Desktop
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
    final color = widget.isDestructive ? Colors.redAccent : theme.colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _isHovering
              ? theme.colorScheme.onSurface.withOpacity(0.04) // Hover sutil
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isDestructive
                      ? Colors.redAccent.withOpacity(0.1)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: color.withOpacity(widget.isDestructive ? 1 : 0.7), size: 20),
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
                        fontWeight: FontWeight.w500, // Fontes um pouco mais finas no desktop
                        color: color,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
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
                  Icons.arrow_forward_ios_rounded, // Chevron menor e mais moderno
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}