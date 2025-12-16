import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dizimista_controller.dart';
import '../models/dizimista_model.dart';
import '../widgets/dizimista_header_view.dart';
import '../widgets/dizimista_search_bar_view.dart';
import '../widgets/dizimista_empty_state_view.dart';
import '../widgets/dizimista_mobile_list_view.dart';
import '../widgets/dizimista_desktop_table_view.dart';
import '../widgets/dizimista_form_dialog.dart';

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
    final backgroundColor = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final accentColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // =======================================================
          // MODERN APP BAR COM GRADIENTE
          // =======================================================
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: surfaceColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Ícone com gradiente
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor,
                                    accentColor.withOpacity(0.8),
                                  ],
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
                              child: Icon(
                                Icons.people_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Título e Subtítulo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fiéis',
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gerenciamento de cadastros',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Botão de adicionar moderno
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor,
                                    accentColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showCadastroDialog(context),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Novo Fiel',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // =======================================================
          // SEARCH BAR
          // =======================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildModernSearchBar(theme, backgroundColor, borderColor, accentColor),
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.crossAxisExtent > 800;

                  if (isDesktop) {
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
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar por nome, CPF, telefone ou endereço...',
          hintStyle: GoogleFonts.inter(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            size: 20,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) return const SizedBox();
            return IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                size: 18,
              ),
              onPressed: () {
                _searchController.clear();
                controller.searchQuery.value = '';
              },
            );
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (val) {
          controller.searchQuery.value = val;
        },
      ),
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