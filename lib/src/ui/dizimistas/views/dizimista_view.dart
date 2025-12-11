import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/dizimista_controller.dart';
import '../models/dizimista_model.dart';

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: surfaceColor,
              child: Column(
                children: [
                  // Linha Superior: Título + Botão Adicionar (Mobile/Desktop)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestão de Fiéis',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Gerencie dizimistas e doadores',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      // Botão "Novo" destacado
                      ElevatedButton.icon(
                        onPressed: () => _showCadastroDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Novo Fiel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Barra de Busca e Filtros
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Buscar por nome, CPF ou telefone...',
                              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                              prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (val) {
                              // Chamar filtro no controller
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botão de Filtro Estilizado
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(Icons.tune_rounded, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                ],
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

                if (controller.dizimistas.isEmpty) {
                  return _buildEmptyState(theme);
                }

                // LayoutBuilder decide se mostra Tabela (Desktop) ou Cards (Mobile)
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;

                    if (isDesktop) {
                      return _buildDesktopTable(controller.dizimistas, theme, surfaceColor);
                    } else {
                      return _buildMobileList(controller.dizimistas, theme, surfaceColor);
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
  // WIDGETS DE CONSTRUÇÃO DE LISTA
  // ===========================================================================
  void _showCadastroDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Controladores de texto
    final nomeController = TextEditingController();
    final cpfController = TextEditingController();
    final telefoneController = TextEditingController();
    final emailController = TextEditingController();
    final enderecoController = TextEditingController();
    final cidadeController = TextEditingController();
    final estadoController = TextEditingController();

    String selectedStatus = 'Ativo';

    // Estilo dos Inputs
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.6)),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder é necessário para o Dropdown funcionar dentro do Dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              actionsPadding: const EdgeInsets.all(24),

              title: Text(
                'Novo Fiel',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              content: SizedBox(
                width: 500, // Largura fixa para ficar bonito em Desktop
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dados Pessoais',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                            letterSpacing: 0.5
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nomeController,
                        style: GoogleFonts.inter(),
                        decoration: inputDecoration.copyWith(labelText: 'Nome Completo'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cpfController,
                              style: GoogleFonts.inter(),
                              decoration: inputDecoration.copyWith(labelText: 'CPF'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: telefoneController,
                              style: GoogleFonts.inter(),
                              decoration: inputDecoration.copyWith(labelText: 'Telefone'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        style: GoogleFonts.inter(),
                        decoration: inputDecoration.copyWith(labelText: 'E-mail'),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Endereço & Status',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                            letterSpacing: 0.5
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: enderecoController,
                        style: GoogleFonts.inter(),
                        decoration: inputDecoration.copyWith(labelText: 'Endereço Completo'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: cidadeController,
                              style: GoogleFonts.inter(),
                              decoration: inputDecoration.copyWith(labelText: 'Cidade'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: estadoController,
                              style: GoogleFonts.inter(),
                              decoration: inputDecoration.copyWith(labelText: 'UF'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Customizado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down_rounded, color: theme.colorScheme.onSurface),
                            style: GoogleFonts.inter(
                              color: theme.colorScheme.onSurface,
                              fontSize: 15,
                            ),
                            dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                            items: ['Ativo', 'Afastado', 'Novo Contribuinte', 'Inativo']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    _StatusBadge(status: value, compact: true),
                                    const SizedBox(width: 10),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validação simples
                    if (nomeController.text.isEmpty) return;

                    final novoDizimista = Dizimista(
                      id: controller.dizimistas.length + 1,
                      nome: nomeController.text,
                      cpf: cpfController.text,
                      telefone: telefoneController.text,
                      email: emailController.text,
                      status: selectedStatus,
                      endereco: enderecoController.text,
                      cidade: cidadeController.text,
                      estado: estadoController.text,
                      dataRegistro: DateTime.now(),
                    );

                    controller.addDizimista(novoDizimista);
                    Navigator.of(context).pop();

                    // Feedback visual (Snackbar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fiel ${nomeController.text} cadastrado com sucesso!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(20),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Salvar Fiel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text(
            'Nenhum fiel encontrado',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          Text(
            'Tente mudar os filtros ou adicione um novo.',
            style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  // --- VISÃO DESKTOP (TABELA MODERNA) ---
  Widget _buildDesktopTable(List<Dizimista> lista, ThemeData theme, Color surfaceColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // Cabeçalho da Tabela
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  _tableHeaderCell('FIEL / CONTATO', flex: 3, theme: theme),
                  _tableHeaderCell('LOCALIZAÇÃO', flex: 2, theme: theme),
                  _tableHeaderCell('STATUS', flex: 1, theme: theme),
                  _tableHeaderCell('CADASTRO', flex: 1, theme: theme),
                  _tableHeaderCell('', flex: 1, theme: theme), // Ações
                ],
              ),
            ),
            const Divider(height: 1),
            // Linhas
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 24, endIndent: 24),
              itemBuilder: (context, index) {
                final d = lista[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      // Coluna 1: Avatar + Nome + Info
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            _buildAvatar(d.nome, theme),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.nome,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.phone_outlined, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                      const SizedBox(width: 4),
                                      Text(
                                        d.telefone,
                                        style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Coluna 2: Endereço
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.endereco, style: GoogleFonts.inter(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${d.cidade} - ${d.estado}', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                          ],
                        ),
                      ),
                      // Coluna 3: Status
                      Expanded(flex: 1, child: Align(alignment: Alignment.centerLeft, child: _StatusBadge(status: d.status))),
                      // Coluna 4: Data
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${d.dataRegistro.day}/${d.dataRegistro.month}/${d.dataRegistro.year}',
                          style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ),
                      // Coluna 5: Ações
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _actionButton(Icons.edit_outlined, Colors.blue, () {}),
                            const SizedBox(width: 8),
                            _actionButton(Icons.delete_outline_rounded, Colors.red, () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- VISÃO MOBILE (LISTA DE CARDS) ---
  Widget _buildMobileList(List<Dizimista> lista, ThemeData theme, Color surfaceColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final d = lista[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(d.nome, theme, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                d.nome,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _StatusBadge(status: d.status, compact: true),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${d.id.toString().padLeft(4, '0')}',
                          style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            const SizedBox(width: 6),
                            Text(d.telefone, style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${d.endereco}, ${d.cidade}',
                                style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Botões de Ação Mobile (Largura total)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text('Histórico'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // COMPONENTES AUXILIARES
  // ===========================================================================

  Widget _tableHeaderCell(String text, {required int flex, required ThemeData theme}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, ThemeData theme, {double size = 40}) {
    // Cores aleatórias baseadas no nome (para ficar bonitinho)
    final colors = [Colors.blue, Colors.purple, Colors.teal, Colors.orange, Colors.pink];
    final color = colors[name.length % colors.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
          style: GoogleFonts.outfit(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }


}

// Badge de Status Reutilizável
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const _StatusBadge({required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'ativo': color = const Color(0xFF22C55E); break; // Green 500
      case 'afastado': color = const Color(0xFFF59E0B); break; // Amber 500
      case 'novo contribuinte': color = const Color(0xFF3B82F6); break; // Blue 500
      default: color = const Color(0xFF64748B); break; // Slate 500
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}