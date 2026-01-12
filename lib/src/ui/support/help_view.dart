import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:intl/intl.dart';

import '../../routes/app_routes.dart';
import '../core/widgets/custom_sliver_app_bar.dart';
import 'package:plataforma_pnsa/src/core/constants/app_constants.dart';

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
    final iconColor = isDark ? theme.colorScheme.primary : theme.primaryColor;

    // Fluent/Material 3 colors
    final surfaceColor =
        isDark ? const Color(0xFF1C1C1C) : const Color(0xFFFFFBFE);
    final cardColor = isDark ? const Color(0xFF2B2B2B) : Colors.white;

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: surfaceColor,
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CustomSliverAppBar(
              title: 'Ajuda',
              subtitle: 'Sistema de Gestão da ${AppConstants.parishName}',
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
                        _buildSystemUpdateCard(theme, isDark),
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
                          iconColor,
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
            // Espaço adicional para o teclado
            SliverToBoxAdapter(
              child: SizedBox(height: bottomPadding + 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsGrid(
    ThemeData theme,
    Color iconColor,
    bool isDark,
    Color cardColor,
    bool isDesktop,
  ) {
    final topics = [
      {
        'icon': Icons.church_outlined,
        'title': 'Cadastro de Fiéis',
        'desc': 'Adicionar e gerenciar membros',
        'content': [
          '• Para cadastrar um novo fiel, clique no botão "+" flutuante na tela de Fiéis.',
          '• Você pode filtrar fiéis por nome, CPF ou endereço na barra de busca.',
          '• A edição de dados é feita clicando no ícone de lápis na listagem.',
          '• O histórico de cada dizimista mostra todas as suas contribuições passadas.',
        ],
      },
      {
        'icon': Icons.payments_outlined,
        'title': 'Controle de Dízimos',
        'desc': 'Registro e acompanhamento',
        'content': [
          '• O lançamento de dízimos é feito na aba de "Contribuições".',
          '• Vincule cada contribuição a um fiel cadastrado ou faça lançamentos avulsos se permitido.',
          '• Após salvar, você pode gerar e compartilhar o recibo em PDF na hora.',
          '• O sistema permite filtrar registros por data, método ou valor.',
        ],
      },
      {
        'icon': Icons.group_work_outlined,
        'title': 'Gestão de Acesso',
        'desc': 'Usuários e permissões',
        'content': [
          '• Administrador: Acesso irrestrito a todas as funções e configurações.',
          '• Secretaria: Foco em cadastros de fiéis e lançamentos diários de dízimo.',
          '• Financeiro: Acesso a relatórios financeiros, fluxo de caixa e gestão de fiéis.',
          '• Agente de Dízimo: Permissão apenas para cadastros e lançamentos em campo.',
        ],
      },
      {
        'icon': Icons.dashboard_outlined,
        'title': 'Painel Administrativo',
        'desc': 'Relatórios e estatísticas',
        'content': [
          '• O Painel (Dashboard) oferece uma visão consolidada da arrecadação.',
          '• Visualize totais do dia, mês atual e ano vigente.',
          '• O sistema gera gráficos de desempenho e variação percentual.',
          '• Relatórios detalhados podem ser exportados para contabilidade na aba Relatórios.',
        ],
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
          children: topics.map((topic) {
            return SizedBox(
              width: width,
              child: SizedBox(
                height: 220, // Altura aumentada para evitar overflow
                child: _buildTopicCard(
                  theme,
                  iconColor,
                  isDark,
                  cardColor,
                  topic['icon'] as IconData,
                  topic['title'] as String,
                  topic['desc'] as String,
                  topic['content'] as List<String>,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context, String title, IconData icon,
      List<String> content, ThemeData theme, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252525) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon,
                          color: theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...content.map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        point,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    )),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Entendi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(
    ThemeData theme,
    Color iconColor,
    bool isDark,
    Color cardColor,
    IconData icon,
    String title,
    String desc,
    List<String> content,
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showHelpDialog(
                      context, title, icon, content, theme, isDark),
                  borderRadius: BorderRadius.circular(16),
                  hoverColor: iconColor.withOpacity(0.04),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: iconColor, size: 26),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
              color: isDark
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

  Widget _buildSystemUpdateCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.sync_rounded, size: 28, color: Colors.green),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistema Atualizado',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Última verificação: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        isDark ? Colors.green.shade200 : Colors.green.shade800,
                    fontWeight: FontWeight.w500,
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
