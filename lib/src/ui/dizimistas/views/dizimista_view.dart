import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

    // Definição de cores modernas
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8);
    final borderColor = theme.dividerColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      // Removemos a AppBar padrão para criar um Header customizado
      body: SafeArea(
        child: Column(
          children: [
            // =======================================================
            // 1. CABEÇALHO E AÇÕES (FIXO NO TOPO)
            // =======================================================
            DizimistaHeaderView(
              onAddPressed: () => _showCadastroDialog(context),
            ),

            // Barra de Busca
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: DizimistaSearchBarView(
                controller: _searchController,
                onChanged: (val) {
                  controller.searchQuery.value = val ?? '';
                },
              ),
            ),

            // =======================================================
            // 2. LISTA DE DADOS (RESPONSIVA)
            // =======================================================
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredDizimistas.isEmpty) {
                  return DizimistaEmptyStateView(searchQuery: controller.searchQuery.value);
                }

                // LayoutBuilder decide se mostra Tabela (Desktop) ou Cards (Mobile)
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;

                    if (isDesktop) {
                      return DizimistaDesktopTableView(
                        lista: controller.filteredDizimistas,
                        theme: theme,
                        surfaceColor: surfaceColor,
                        onEditPressed: (dizimista) => _showEditarDialog(context, dizimista),
                      );
                    } else {
                      return DizimistaMobileListView(
                        lista: controller.filteredDizimistas,
                        theme: theme,
                        surfaceColor: surfaceColor,
                        onEditPressed: (dizimista) => _showEditarDialog(context, dizimista),
                        onViewHistoryPressed: (dizimista) {},
                      );
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // MÉTODOS DE AÇÃO
  // ===========================================================================

  void _showCadastroDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DizimistaFormDialog(
          title: 'Novo Fiel',
          onSave: (dizimista) {
            controller.addDizimista(dizimista);
            Navigator.of(context).pop();

            // Feedback visual (Snackbar)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fiel ${dizimista.nome} cadastrado com sucesso!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(20),
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
      builder: (BuildContext context) {
        return DizimistaFormDialog(
          dizimista: dizimista,
          title: 'Editar Fiel',
          onSave: (dizimistaAtualizado) {
            controller.updateDizimista(dizimistaAtualizado);
            Navigator.of(context).pop();

            // Feedback visual (Snackbar)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fiel ${dizimistaAtualizado.nome} atualizado com sucesso!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(20),
              ),
            );
          },
        );
      },
    );
  }

  // Função auxiliar para formatar CPF com máscara
  String _formatarCPF(String cpf) {
    // Remove caracteres não numéricos
    String cpfNumerico = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (cpfNumerico.length != 11) return cpf; // Retorna o valor original se não tiver 11 dígitos
    return "${cpfNumerico.substring(0, 3)}.${cpfNumerico.substring(3, 6)}.${cpfNumerico.substring(6, 9)}-${cpfNumerico.substring(9, 11)}";
  }

  // Função auxiliar para formatar telefone com máscara
  String _formatarTelefone(String telefone) {
    // Remove caracteres não numéricos
    String telefoneNumerico = telefone.replaceAll(RegExp(r'[^\d]'), '');

    if (telefoneNumerico.length < 10) return telefone; // Retorna o valor original se não tiver dígitos suficientes

    if (telefoneNumerico.length == 10) { // Telefone fixo (8 dígitos + 2 dígitos DDD)
      return "(${telefoneNumerico.substring(0, 2)}) ${telefoneNumerico.substring(2, 6)}-${telefoneNumerico.substring(6, 10)}";
    } else { // Celular (9 dígitos + 2 dígitos DDD)
      return "(${telefoneNumerico.substring(0, 2)}) ${telefoneNumerico.substring(2, 7)}-${telefoneNumerico.substring(7, 11)}";
    }
  }
}