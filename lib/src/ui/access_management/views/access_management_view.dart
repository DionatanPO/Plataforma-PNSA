import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/access_management_controller.dart';
import '../models/acesso_model.dart';
import '../models/funcao_model.dart';

class AccessManagementView extends StatefulWidget {
  const AccessManagementView({Key? key}) : super(key: key);

  @override
  State<AccessManagementView> createState() => _AccessManagementViewState();
}

class _AccessManagementViewState extends State<AccessManagementView> {
  final AccessManagementController controller = Get.find<AccessManagementController>();
  final TextEditingController _searchController = TextEditingController();

  // Variáveis de Tema
  late ThemeData theme;
  late bool isDark;
  late Color surfaceColor;
  late Color backgroundColor;
  late Color borderColor;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    isDark = theme.brightness == Brightness.dark;
    surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8);
    borderColor = theme.dividerColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      // Header flutuante integrado ao corpo
      body: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // 1. HEADER (TÍTULO + AÇÃO)
            // ========================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              color: surfaceColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestão de Acesso',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Administre usuários e permissões do sistema',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botão Desktop (No mobile ele pode virar um FAB ou ícone menor se quiser)
                  ElevatedButton.icon(
                    onPressed: _openAddUserDialog,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Novo Usuário'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // 2. CONTEÚDO PRINCIPAL (BUSCA + LISTA)
            // ========================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Barra de Busca Estilizada
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nome ou e-mail...',
                          hintStyle: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                          prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onChanged: (value) => controller.setSearchQuery(value),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // LISTAGEM RESPONSIVA
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (controller.filteredAcessos.isEmpty) {
                          return _buildEmptyState();
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            // Se a tela for larga (> 800px), mostra Tabela. Senão, mostra Cards.
                            if (constraints.maxWidth > 800) {
                              return _buildDesktopTable(controller.filteredAcessos);
                            } else {
                              return _buildMobileList(controller.filteredAcessos);
                            }
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGETS DE LISTAGEM (DESKTOP vs MOBILE)
  // ===========================================================================

  // Tabela para telas grandes
  Widget _buildDesktopTable(List<Acesso> lista) {
    return Container(
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
                _tableHeader('USUÁRIO', flex: 3),
                _tableHeader('FUNÇÃO', flex: 2),
                _tableHeader('STATUS', flex: 1),
                _tableHeader('ÚLTIMO ACESSO', flex: 2),
                _tableHeader('AÇÕES', flex: 1, alignRight: true),
              ],
            ),
          ),
          const Divider(height: 1),
          // Linhas da Tabela
          Expanded(
            child: ListView.separated(
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 24, endIndent: 24),
              itemBuilder: (context, index) {
                final acesso = lista[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      // Coluna 1: Avatar e Nome
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            _buildAvatar(acesso.nome),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(acesso.nome, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                                  Text(acesso.email, style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Coluna 2: Função
                      Expanded(
                        flex: 2,
                        child: Text(acesso.funcao, style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                      ),
                      // Coluna 3: Status
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusBadge(status: acesso.status),
                        ),
                      ),
                      // Coluna 4: Data
                      Expanded(
                        flex: 2,
                        child: Text(
                          controller.formatarData(acesso.ultimoAcesso),
                          style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ),
                      // Coluna 5: Ações
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _actionButton(Icons.edit_outlined, Colors.blue),
                            const SizedBox(width: 8),
                            _actionButton(Icons.delete_outline, Colors.red),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Cards para telas pequenas
  Widget _buildMobileList(List<Acesso> lista) {
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final acesso = lista[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildAvatar(acesso.nome, size: 40),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(acesso.nome, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(acesso.funcao, style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                    ],
                  ),
                  _StatusBadge(status: acesso.status, compact: true),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Último acesso', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                      const SizedBox(height: 2),
                      Text(controller.formatarData(acesso.ultimoAcesso), style: GoogleFonts.inter(fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: (){}, icon: Icon(Icons.edit, size: 20, color: theme.colorScheme.primary)),
                      IconButton(onPressed: (){}, icon: const Icon(Icons.delete, size: 20, color: Colors.red)),
                    ],
                  )
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

  Widget _tableHeader(String text, {required int flex, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.end : TextAlign.start,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildAvatar(String nome, {double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10), // Quadrado arredondado (Moderno)
      ),
      child: Center(
        child: Text(
          controller.getInitials(nome),
          style: GoogleFonts.outfit(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text('Nenhum usuário encontrado', style: GoogleFonts.outfit(fontSize: 18, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIALOGO MODERNO DE ADIÇÃO
  // ===========================================================================

  void _openAddUserDialog() {
    // Controladores locais
    String nome = '';
    String email = '';
    String funcao = 'Administrador';
    String status = 'Ativo';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: surfaceColor,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Novo Usuário', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                content: SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Dados Pessoais'),
                        _buildTextField(label: 'Nome Completo', onChanged: (v) => nome = v),
                        const SizedBox(height: 16),
                        _buildTextField(label: 'E-mail Corporativo', onChanged: (v) => email = v),
                        const SizedBox(height: 24),

                        _label('Permissões'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'Função',
                                value: funcao,
                                items: controller.getFuncoes().map((f) => f.nome).toList(),
                                onChanged: (v) => setState(() => funcao = v!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                label: 'Status',
                                value: status,
                                items: ['Ativo', 'Inativo'],
                                onChanged: (v) => setState(() => status = v!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nome.isNotEmpty && email.isNotEmpty) {
                        final novoAcesso = Acesso(
                          id: controller.acessos.length + 1,
                          nome: nome,
                          email: email,
                          funcao: funcao,
                          status: status,
                          ultimoAcesso: DateTime.now(),
                        );
                        controller.addAcesso(novoAcesso);
                        Navigator.pop(context);

                        Get.snackbar(
                          'Sucesso', 'Usuário $nome adicionado.',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(24),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Criar Acesso'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // Helpers para o Dialog
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor)),
  );

  Widget _buildTextField({required String label, required Function(String) onChanged}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: GoogleFonts.inter(fontSize: 14),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.inter(fontSize: 14)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// COMPONENTE DE STATUS (Reutilizado para consistência)
// =============================================================================
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const _StatusBadge({required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Ativo': color = Colors.green; break;
      case 'Inativo': color = Colors.grey; break;
      default: color = Colors.blue;
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
        ),
      ),
    );
  }
}