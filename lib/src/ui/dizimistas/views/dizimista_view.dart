import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dizimista_controller.dart';
import '../models/dizimista_model.dart';
import '../widgets/dizimista_empty_state_view.dart';
import '../widgets/dizimista_mobile_list_view.dart';
import '../widgets/dizimista_desktop_table_view.dart';
import '../widgets/dizimista_form_dialog.dart';
import '../widgets/dizimista_search_bar_view.dart';
import '../../core/widgets/modern_header.dart';

class DizimistaView extends StatefulWidget {
  const DizimistaView({Key? key}) : super(key: key);

  @override
  State<DizimistaView> createState() => _DizimistaViewState();
}

class _DizimistaViewState extends State<DizimistaView> {
  final DizimistaController controller = Get.find<DizimistaController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cores modernas e refinadas
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final backgroundColor =
        isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final accentColor = theme.primaryColor;

    // Medidas responsivas
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final double horizontalPadding = isDesktop ? 24.0 : 12.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          // =======================================================
          // MODERN APP BAR COM GRADIENTE
          // =======================================================
          // =======================================================
          // MODERN HEADER
          // =======================================================
          ModernHeader(
            title: 'Fiéis',
            subtitle: 'Gerenciamento de cadastros',
            icon: Icons.people_rounded,
          ),

          // =======================================================
          // SEARCH BAR
          // =======================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isDesktop ? 24 : 16,
                horizontalPadding,
                isDesktop ? 24 : 16,
              ),
              child: _buildModernSearchBar(
                theme,
                backgroundColor,
                borderColor,
                accentColor,
              ),
            ),
          ),
          // =======================================================
          // LISTA DE DADOS (RESPONSIVA)
          // =======================================================
          Obx(() {
            if (controller.isLoading) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accentColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carregando fiéis...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.filteredDizimistas.isEmpty) {
              return SliverFillRemaining(
                child: DizimistaEmptyStateView(
                  searchQuery: controller.searchQuery.value,
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                24,
              ),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  // Reutilizando lógica de desktop se quiser, mas já temos isDesktop no escopo acima
                  // Porém constraints aqui é mais preciso para o Sliver
                  final bool isWide = constraints.crossAxisExtent > 800;

                  if (isWide) {
                    return SliverToBoxAdapter(
                      child: DizimistaDesktopTableView(
                        lista: controller.filteredDizimistas,
                        theme: theme,
                        surfaceColor: surfaceColor,
                        onEditPressed: (dizimista) =>
                            _showEditarDialog(context, dizimista),
                      ),
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: DizimistaMobileListView(
                        lista: controller.filteredDizimistas,
                        theme: theme,
                        surfaceColor: surfaceColor,
                        onEditPressed: (dizimista) =>
                            _showEditarDialog(context, dizimista),
                        onViewHistoryPressed: (dizimista) {},
                      ),
                    );
                  }
                },
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dizimista_fab',
        onPressed: () => _showCadastroDialog(context),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Novo Fiel',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // =======================================================
  // SEARCH BAR MODERNA
  // =======================================================
  Widget _buildModernSearchBar(
    ThemeData theme,
    Color backgroundColor,
    Color borderColor,
    Color accentColor,
  ) {
    return DizimistaSearchBarView(
      controller: _searchController,
      onChanged: (val) {
        controller.searchQuery.value = val;
      },
    );
  }

  // ===========================================================================
  // MÉTODOS DE AÇÃO
  // ===========================================================================

  void _showCadastroDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return DizimistaFormDialog(
          title: 'Novo Fiel',
          onSave: (dizimista) {
            controller.addDizimista(dizimista);
            Navigator.of(context).pop();

            // Feedback visual moderno
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Fiel cadastrado!',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            dizimista.nome,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(20),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditarDialog(BuildContext context, Dizimista dizimista) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return DizimistaFormDialog(
          dizimista: dizimista,
          title: 'Editar Fiel',
          onSave: (dizimistaAtualizado) {
            controller.updateDizimista(dizimistaAtualizado);
            Navigator.of(context).pop();

            // Feedback visual moderno
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Fiel atualizado!',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            dizimistaAtualizado.nome,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(20),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // FUNÇÕES AUXILIARES DE FORMATAÇÃO
  // ===========================================================================

  String _formatarCPF(String cpf) {
    String cpfNumerico = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cpfNumerico.length != 11) return cpf;
    return "${cpfNumerico.substring(0, 3)}.${cpfNumerico.substring(3, 6)}.${cpfNumerico.substring(6, 9)}-${cpfNumerico.substring(9, 11)}";
  }

  String _formatarTelefone(String telefone) {
    String telefoneNumerico = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (telefoneNumerico.length < 10) return telefone;

    if (telefoneNumerico.length == 10) {
      return "(${telefoneNumerico.substring(0, 2)}) ${telefoneNumerico.substring(2, 6)}-${telefoneNumerico.substring(6, 10)}";
    } else {
      return "(${telefoneNumerico.substring(0, 2)}) ${telefoneNumerico.substring(2, 7)}-${telefoneNumerico.substring(7, 11)}";
    }
  }
}

// =======================================================
// WIDGET DE SEARCH BAR MODERNA REUTILIZÁVEL
// =======================================================
class _ModernSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ThemeData theme;
  final Color backgroundColor;
  final Color accentColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _ModernSearchBar({
    required this.controller,
    required this.theme,
    required this.backgroundColor,
    required this.accentColor,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<_ModernSearchBar> {
  bool _isFocused = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isDark = theme.brightness == Brightness.dark;

    // Cores modernas e refinadas
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final inputBgColor =
        isDark ? const Color(0xFF252525) : const Color(0xFFF8FAFC);
    final accentColor = widget.accentColor;

    // Cores de estado
    final borderColor = _isFocused
        ? accentColor.withOpacity(0.5)
        : (_isHovering
            ? theme.dividerColor.withOpacity(0.2)
            : theme.dividerColor.withOpacity(0.1));

    final iconColor =
        _isFocused ? accentColor : theme.colorScheme.onSurface.withOpacity(0.4);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: _isFocused ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? accentColor.withOpacity(0.08)
                  : Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: _isFocused ? 20 : 12,
              offset: const Offset(0, 4),
              spreadRadius: _isFocused ? 2 : 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone de busca com container estilizado
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isFocused ? accentColor.withOpacity(0.1) : inputBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.search_rounded, color: iconColor, size: 18),
            ),

            // Campo de texto
            Expanded(
              child: Focus(
                onFocusChange: (focused) =>
                    setState(() => _isFocused = focused),
                child: TextField(
                  controller: widget.controller,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, CPF, telefone ou endereço...',
                    hintStyle: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface.withOpacity(0.35),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
            ),

            // Botão de limpar (aparece apenas quando há texto)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: widget.controller.text.isNotEmpty
                  ? Container(
                      key: const ValueKey('clear'),
                      margin: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onClear,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.05,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: 16, key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}
