import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../domain/models/acesso_model.dart';
import '../controllers/access_management_controller.dart';

class AccessFormDesktopView extends StatefulWidget {
  final Acesso? acesso;

  const AccessFormDesktopView({Key? key, this.acesso}) : super(key: key);

  @override
  State<AccessFormDesktopView> createState() => _AccessFormDesktopViewState();
}

class _AccessFormDesktopViewState extends State<AccessFormDesktopView> {
  final _formKey = GlobalKey<FormState>();
  final AccessManagementController _controller =
      Get.find<AccessManagementController>();
  final ScrollController _scrollController = ScrollController();

  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController cpfController;
  late TextEditingController telefoneController;
  late TextEditingController enderecoController;

  final cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
  final telefoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');

  String? funcao;
  String? status;
  int activeSection = 0;

  bool get isEditing => widget.acesso != null;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final a = widget.acesso;
    nomeController = TextEditingController(text: a?.nome ?? '');
    emailController = TextEditingController(text: a?.email ?? '');
    cpfController = TextEditingController(
        text: a != null ? cpfFormatter.maskText(a.cpf) : '');
    telefoneController = TextEditingController(
        text: a != null ? telefoneFormatter.maskText(a.telefone) : '');
    enderecoController = TextEditingController(text: a?.endereco ?? '');
    funcao = a?.funcao ?? 'Administrador';
    status = a?.status ?? 'Ativo';
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    enderecoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    setState(() => activeSection = index);
    _scrollController.animateTo(index * 400.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final acesso = Acesso(
        id: widget.acesso?.id ??
            (DateTime.now().millisecondsSinceEpoch % 10000).toString(),
        nome: nomeController.text,
        email: emailController.text,
        cpf: cpfFormatter.unmaskText(cpfController.text),
        telefone: telefoneFormatter.unmaskText(telefoneController.text),
        endereco: enderecoController.text,
        funcao: funcao ?? 'Administrador',
        status: status ?? 'Ativo',
        ultimoAcesso: widget.acesso?.ultimoAcesso,
        pendencia: widget.acesso?.pendencia ?? true,
      );

      try {
        if (isEditing) {
          await _controller.updateAcesso(acesso);
        } else {
          await _controller.addAcesso(acesso);
        }
        Get.back();
        Get.snackbar('Sucesso',
            isEditing ? 'Usuário atualizado.' : 'Novo usuário criado.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(24));
      } catch (e) {
        String msg = e.toString();
        if (msg.startsWith('Exception: ')) {
          msg = msg.replaceFirst('Exception: ', '');
        }
        _showErrorDialog(msg);
      }
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Ops! Atenção',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Theme.of(context).hintColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Get.back(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Entendi',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF0F2F5),
      body: Row(
        children: [
          _buildSidebar(theme, isDark),
          Expanded(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(theme, isDark),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(32, 24, 16, 120),
                            child: Column(
                              children: [
                                _buildSection(0, 'Informações Pessoais',
                                    Icons.person_outline, theme, [
                                  _buildRow([
                                    _buildTextField(nomeController,
                                        'Nome Completo', Icons.person,
                                        flex: 2,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obrigatório' : null),
                                    _buildTextField(emailController,
                                        'E-mail Corporativo', Icons.email,
                                        flex: 2,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obrigatório' : null),
                                  ]),
                                  const SizedBox(height: 16),
                                  _buildRow([
                                    _buildTextField(
                                        cpfController, 'CPF', Icons.fingerprint,
                                        formatter: cpfFormatter,
                                        flex: 1,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obrigatório' : null),
                                    _buildTextField(telefoneController,
                                        'Celular', Icons.phone_iphone,
                                        formatter: telefoneFormatter,
                                        flex: 1,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obrigatório' : null),
                                  ]),
                                  const SizedBox(height: 16),
                                  // Campo único, sem estar dentro de Row para evitar erro de Expanded
                                  TextFormField(
                                    controller: enderecoController,
                                    decoration: _buildInputDecoration(
                                        theme,
                                        'Endereço Completo',
                                        Icons.location_on_outlined),
                                    onChanged: (v) => setState(() {}),
                                  ),
                                ]),
                                const SizedBox(height: 24),
                                _buildSection(1, 'Nível de Acesso',
                                    Icons.security_rounded, theme, [
                                  _buildRow([
                                    _buildDropdown(
                                        'Função do Usuário',
                                        funcao,
                                        _controller
                                            .getFuncoes()
                                            .map((f) => f.nome)
                                            .toList(),
                                        (v) => setState(() => funcao = v),
                                        Icons.admin_panel_settings),
                                    if (isEditing)
                                      _buildDropdown(
                                          'Status da Conta',
                                          status,
                                          ['Ativo', 'Inativo'],
                                          (v) => setState(() => status = v),
                                          Icons.info_outline),
                                  ]),
                                  const SizedBox(height: 24),
                                  _buildSecurityNote(theme),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        _buildPreviewCard(theme, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(theme, isDark),
    );
  }

  Widget _buildSidebar(ThemeData theme, bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
            right: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: [
                CircleAvatar(
                    radius: 35,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.manage_accounts_rounded,
                        color: theme.primaryColor, size: 35)),
                const SizedBox(height: 16),
                Text(isEditing ? 'Editar Usuário' : 'Novo Usuário',
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Configuração de credenciais',
                    style: TextStyle(color: theme.hintColor, fontSize: 13)),
              ],
            ),
          ),
          const Divider(),
          _buildSidebarItem(0, 'Identidade', Icons.person_outline, theme),
          _buildSidebarItem(1, 'Permissões', Icons.security_rounded, theme),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Acesso Manger 2.0',
                style: TextStyle(
                    color: theme.hintColor.withOpacity(0.5), fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      int index, String label, IconData icon, ThemeData theme) {
    bool isActive = activeSection == index;
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _scrollToSection(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    color: isActive
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 4)),
            color: isActive
                ? theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isActive ? theme.colorScheme.primary : theme.hintColor,
                  size: 20),
              const SizedBox(width: 16),
              Text(label,
                  style: GoogleFonts.inter(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.hintColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Row(
        children: [
          IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
          const SizedBox(width: 8),
          Text('Acessos / Gerenciar Usuário',
              style: GoogleFonts.outfit(fontSize: 14, color: theme.hintColor)),
        ],
      ),
    );
  }

  Widget _buildSection(int id, String title, IconData icon, ThemeData theme,
      List<Widget> children) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon,
                      color: isDark
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.8),
                      size: 22)),
              const SizedBox(width: 16),
              Text(title,
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int flex = 1,
      MaskTextInputFormatter? formatter,
      String? Function(String?)? validator}) {
    // IMPORTANTE: _buildTextField agora NÃO retorna Expanded. O Expanded é tratado no _buildRow.
    return TextFormField(
      controller: controller,
      inputFormatters: formatter != null ? [formatter] : [],
      validator: validator,
      decoration: _buildInputDecoration(Theme.of(context), label, icon),
      onChanged: (v) => setState(() {}),
    );
  }

  Widget _buildRow(List<Widget> children) {
    // Envolvemos os filhos em Expanded apenas aqui, de forma controlada.
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((e) => Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(right: 16), child: e)))
            .toList());
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged, IconData icon) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: _buildInputDecoration(Theme.of(context), label, icon),
    );
  }

  Widget _buildSecurityNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primaryColor.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: theme.primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Segurança de Acesso',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                    'Ao criar um novo perfil, o sistema gera automaticamente uma senha temporária (123456). O usuário será solicitado a trocá-la no primeiro acesso.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: theme.hintColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme, bool isDark) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                      : [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8)
                        ]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: theme.primaryColor.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle_outlined,
                    color: Colors.white70, size: 40),
                const SizedBox(height: 40),
                Text(
                    nomeController.text.isEmpty
                        ? 'NOME DO USUÁRIO'
                        : nomeController.text.toUpperCase(),
                    style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(
                    emailController.text.isEmpty
                        ? 'email@paroquia.com'
                        : emailController.text,
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(funcao?.toUpperCase() ?? 'PRIVILÉGIO',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoItem('Status da Conta', status ?? 'Ativo',
              status == 'Ativo' ? Colors.green : Colors.orange, theme),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 13)),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
              top: BorderSide(color: theme.dividerColor.withOpacity(0.1)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Cancelar')),
          const SizedBox(width: 16),
          Obx(() => FilledButton(
              onPressed: _controller.isLoading ? null : _submitForm,
              style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: _controller.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? 'Salvar Alterações' : 'Criar Conta'))),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      ThemeData theme, String label, IconData icon) {
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon,
          size: 20,
          color: isDark
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.7)),
      labelStyle: TextStyle(color: theme.hintColor, fontSize: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2)),
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? Colors.white.withOpacity(0.03)
          : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
