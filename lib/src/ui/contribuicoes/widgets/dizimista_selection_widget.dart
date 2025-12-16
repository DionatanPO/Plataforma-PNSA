import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/contribuicao_controller.dart';
import '../../dizimistas/controllers/dizimista_controller.dart';
import '../../dizimistas/models/dizimista_model.dart';

class DizimistaSelectionWidget extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function()? onDizimistaSelected;

  const DizimistaSelectionWidget({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    this.onDizimistaSelected,
  }) : super(key: key);

  @override
  State<DizimistaSelectionWidget> createState() => _DizimistaSelectionWidgetState();
}

class _DizimistaSelectionWidgetState extends State<DizimistaSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContribuicaoController>();
    final dizimistaController = Get.find<DizimistaController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F6F8);
    final borderColor = theme.dividerColor.withOpacity(0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da etapa
        Text(
          'Selecione o Fiél',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Campo de busca
        _buildLabel('Buscar Fiéis', theme),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome, CPF ou telefone...',
              hintStyle: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
        ),

        const SizedBox(height: 16),

        // Lista de resultados da busca
        if (widget.searchController.text.isNotEmpty) ...[
          _buildLabel('Resultados da Busca', theme),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Obx(() {
              final selecionado = controller.dizimistaSelecionado.value;
              return FutureBuilder<List<Dizimista>>(
                future: controller.searchDizimistasFirestore(widget.searchController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final List<Dizimista> dizimistasFiltrados = snapshot.data ?? [];

                  if (dizimistasFiltrados.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum fiel encontrado',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Nenhum fiel corresponde à sua pesquisa',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dizimistasFiltrados.length,
                    itemBuilder: (context, index) {
                      final dizimista = dizimistasFiltrados[index];
                      final isSelected = selecionado?.id == dizimista.id;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                dizimista.nome.isNotEmpty && dizimista.nome.split(' ').length > 1
                                    ? '${dizimista.nome.split(' ')[0][0]}${dizimista.nome.split(' ').last[0]}'.toUpperCase()
                                    : dizimista.nome.isNotEmpty ? dizimista.nome[0].toUpperCase() : '?',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            dizimista.nome,
                            style: GoogleFonts.outfit(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'CPF: ${dizimista.cpf} | Tel: ${dizimista.telefone}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                              : null,
                          onTap: () {
                            controller.dizimistaSelecionado.value = dizimista;
                            if (widget.onDizimistaSelected != null) {
                              widget.onDizimistaSelected!();
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ] else if (controller.dizimistaSelecionado.value != null) ...[
          // Mostrar o dizimista selecionado quando nenhum texto é digitado mas um dizimista está selecionado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Fiel Selecionado',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  controller.dizimistaSelecionado.value?.nome ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Digite para pesquisar fiéis',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Comece digitando um nome, CPF ou telefone',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Mensagem de confirmação
        if (controller.dizimistaSelecionado.value != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Fiél selecionado: ${controller.dizimistaSelecionado.value?.nome}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}