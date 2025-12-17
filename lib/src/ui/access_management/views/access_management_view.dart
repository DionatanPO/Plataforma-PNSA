import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../domain/models/acesso_model.dart';
import '../controllers/access_management_controller.dart';
import '../widgets/access_management_header.dart';
import '../widgets/access_management_search_bar.dart';
import '../widgets/access_management_desktop_list.dart';
import '../widgets/access_management_mobile_list.dart';
import '../widgets/access_management_function_cards.dart';
import '../widgets/access_management_status_cards.dart';
import '../widgets/password_reset_info_card.dart';
import '../widgets/first_access_info_card.dart';
import '../widgets/access_management_empty_state.dart';

class AccessManagementView extends StatefulWidget {
  const AccessManagementView({Key? key}) : super(key: key);

  @override
  State<AccessManagementView> createState() => _AccessManagementViewState();
}

class _AccessManagementViewState extends State<AccessManagementView> {
  final AccessManagementController controller =
      Get.find<AccessManagementController>();
  final TextEditingController _searchController = TextEditingController();

  // Variáveis de Tema (inicializadas no build)
  late ThemeData theme;
  late bool isDark;
  late Color surfaceColor;
  late Color backgroundColor;
  late Color borderColor;

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    isDark = theme.brightness == Brightness.dark;
    surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F6F8);
    borderColor = theme.dividerColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const AccessManagementHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                isMobile ? 16 : 24,
                isMobile ? 16 : 24,
                isMobile ? 16 : 24,
              ),
              child: AccessManagementSearchBar(
                controller: _searchController,
                onChanged: (value) => controller.setSearchQuery(value),
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.filteredAcessos.isEmpty) {
              return SliverToBoxAdapter(
                child: AccessManagementEmptyState(
                  searchQuery: controller.searchQuery,
                ),
              );
            }
            return SliverLayoutBuilder(
              builder: (context, constraints) {
                if (constraints.crossAxisExtent > 850) {
                  return AccessManagementDesktopList(
                    acessos: controller.filteredAcessos,
                    onEditUser: _openEditUserDialog,
                    onResetPassword: _openResetPasswordDialog,
                    theme: theme,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                  );
                } else {
                  return AccessManagementMobileList(
                    acessos: controller.filteredAcessos,
                    onEditUser: _openEditUserDialog,
                    onResetPassword: _openResetPasswordDialog,
                    theme: theme,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                  );
                }
              },
            );
          }),
          _buildInfoSectionSliver(
            'Definições de Funções',
            const AccessManagementFunctionCards(),
          ),
          _buildInfoSectionSliver(
            'Legenda de Status',
            const AccessManagementStatusCards(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 24,
                isMobile ? 24 : 40,
                isMobile ? 16 : 24,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Como Funciona o Sistema de Senhas',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 700) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: const PasswordResetInfoCard()),
                            const SizedBox(width: 16),
                            Expanded(child: const FirstAccessInfoCard()),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            const PasswordResetInfoCard(),
                            const SizedBox(height: 12),
                            const FirstAccessInfoCard(),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddUserDialog,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Novo Usuário',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ===========================================================================
  // SEÇÕES DE INFORMAÇÃO (Helpers)
  // ===========================================================================

  Widget _buildInfoSectionSliver(String title, Widget content) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 24,
          isMobile ? 24 : 40,
          isMobile ? 16 : 24,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  void _openEditUserDialog(Acesso acesso) {
    final nomeController = TextEditingController(text: acesso.nome);
    final emailController = TextEditingController(text: acesso.email);
    final enderecoController = TextEditingController(text: acesso.endereco);
    final cpfController = TextEditingController();
    final telefoneController = TextEditingController();
    String funcao = acesso.funcao;
    String status = acesso.status;

    final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
    );
    cpfController.text = cpfFormatter.maskText(acesso.cpf);

    final telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );
    telefoneController.text = telefoneFormatter.maskText(acesso.telefone);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget formContent = SingleChildScrollView(
              padding: isMobile ? const EdgeInsets.all(16) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile) _label('Dados Pessoais'),
                  _buildTextField(
                    label: 'Nome Completo',
                    controller: nomeController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'E-mail Corporativo',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'CPF',
                          controller: cpfController,
                          inputFormatters: [cpfFormatter],
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Celular',
                          controller: telefoneController,
                          inputFormatters: [telefoneFormatter],
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Endereço',
                    controller: enderecoController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 24),
                  if (!isMobile) _label('Permissões'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Função',
                          value: funcao,
                          items: controller
                              .getFuncoes()
                              .map((f) => f.nome)
                              .toList(),
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
            );

            void submit() {
              if (nomeController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                final acessoAtualizado = Acesso(
                  id: acesso.id,
                  nome: nomeController.text,
                  email: emailController.text,
                  cpf: cpfFormatter.getUnmaskedText(),
                  telefone: telefoneFormatter.getUnmaskedText(),
                  endereco: enderecoController.text,
                  funcao: funcao,
                  status: status,
                  ultimoAcesso: acesso.ultimoAcesso,
                  pendencia: acesso.pendencia,
                );
                controller.updateAcesso(acessoAtualizado);
                Navigator.pop(context);
              }
            }

            if (isMobile) {
              return Dialog.fullscreen(
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Editar Usuário'),
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      TextButton(
                        onPressed: submit,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                  body: formContent,
                ),
              );
            }

            return AlertDialog(
              backgroundColor: surfaceColor,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Editar Usuário',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(width: 500, child: formContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Salvar Alterações'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openResetPasswordDialog(Acesso acesso) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          ),
          title: Text(
            'Redefinir Senha',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Deseja redefinir a senha do usuário ${acesso.nome} para o padrão 123456? Esta ação definirá a pendência de troca de senha para este usuário.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Atualizar o campo pendencia para true
                final acessoAtualizado = Acesso(
                  id: acesso.id,
                  nome: acesso.nome,
                  email: acesso.email,
                  cpf: acesso.cpf,
                  telefone: acesso.telefone,
                  endereco: acesso.endereco,
                  funcao: acesso.funcao,
                  status: acesso.status,
                  ultimoAcesso: acesso.ultimoAcesso,
                  pendencia:
                      true, // Definir pendência como true para forçar troca de senha
                );

                await controller.updateAcesso(acessoAtualizado);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Senha do usuário ${acesso.nome} redefinida. A pendência de troca de senha foi ativada.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Redefinir'),
            ),
          ],
        );
      },
    );
  }

  void _openAddUserDialog() {
    String nome = '';
    String email = '';
    String cpf = '';
    String telefone = '';
    String endereco = '';
    String funcao = 'Administrador';
    String status = 'Ativo';

    final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
    );
    final telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget formContent = SingleChildScrollView(
              padding: isMobile ? const EdgeInsets.all(16) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile) _label('Dados Pessoais'),
                  _buildTextField(
                    label: 'Nome Completo',
                    onChanged: (v) => nome = v,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'E-mail Corporativo',
                    onChanged: (v) => email = v,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'CPF',
                          onChanged: (v) => cpf = v,
                          inputFormatters: [cpfFormatter],
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Celular',
                          onChanged: (v) => telefone = v,
                          inputFormatters: [telefoneFormatter],
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Endereço',
                    onChanged: (v) => endereco = v,
                  ),
                  const SizedBox(height: 24),
                  if (!isMobile) _label('Permissões'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Função',
                          value: funcao,
                          items: controller
                              .getFuncoes()
                              .map((f) => f.nome)
                              .toList(),
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
            );

            void submit() {
              if (nome.isNotEmpty && email.isNotEmpty) {
                final cpfSemMascara = cpf.replaceAll(RegExp(r'[^\d]'), '');
                final telefoneSemMascara = telefone.replaceAll(
                  RegExp(r'[^\d]'),
                  '',
                );
                final novoAcesso = Acesso(
                  id: (controller.acessos.length + 1).toString(),
                  nome: nome,
                  email: email,
                  cpf: cpfSemMascara,
                  telefone: telefoneSemMascara,
                  endereco: endereco,
                  funcao: funcao,
                  status: status,
                  ultimoAcesso: DateTime.now(),
                  pendencia: true,
                );
                controller.addAcesso(novoAcesso);
                Navigator.pop(context);
              }
            }

            if (isMobile) {
              return Dialog.fullscreen(
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Novo Usuário'),
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      TextButton(
                        onPressed: submit,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Criar'),
                      ),
                    ],
                  ),
                  body: formContent,
                ),
              );
            }

            return AlertDialog(
              backgroundColor: surfaceColor,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Novo Usuário',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(width: 500, child: formContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Criar Acesso'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
    ),
  );

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    style: GoogleFonts.inter(fontSize: 14),
    onChanged: onChanged,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
  );

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: GoogleFonts.inter(fontSize: 14)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}
