import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../domain/models/acesso_model.dart';
import '../controllers/access_management_controller.dart';
import './access_form_desktop_view.dart';

class AccessFormView extends StatefulWidget {
  final Acesso? acesso;

  const AccessFormView({Key? key, this.acesso}) : super(key: key);

  @override
  State<AccessFormView> createState() => _AccessFormViewState();
}

class _AccessFormViewState extends State<AccessFormView> {
  final _formKey = GlobalKey<FormState>();

  // Usamos Get.find diretamente para evitar loops de inicialização
  late final AccessManagementController _controller;

  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController cpfController;
  late TextEditingController telefoneController;
  late TextEditingController enderecoController;

  late MaskTextInputFormatter cpfFormatter;
  late MaskTextInputFormatter telefoneFormatter;

  String? funcao;
  String? status;
  int _currentMobileStep = 0;

  bool get isEditing => widget.acesso != null;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AccessManagementController>();

    cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
    telefoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');

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
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cpfSemMascara = cpfFormatter.unmaskText(cpfController.text);
      final telefoneSemMascara =
          telefoneFormatter.unmaskText(telefoneController.text);

      final acesso = Acesso(
        id: widget.acesso?.id ??
            (DateTime.now().millisecondsSinceEpoch % 10000).toString(),
        nome: nomeController.text,
        email: emailController.text,
        cpf: cpfSemMascara,
        telefone: telefoneSemMascara,
        endereco: enderecoController.text,
        funcao: funcao ?? 'Administrador',
        status: status ?? 'Ativo',
        ultimoAcesso: widget.acesso?.ultimoAcesso, // Fica null se for novo
        pendencia: widget.acesso?.pendencia ?? true,
      );

      try {
        if (isEditing) {
          await _controller.updateAcesso(acesso);
        } else {
          await _controller.addAcesso(acesso);
        }
        Get.back();
        Get.snackbar(
          'Sucesso',
          isEditing ? 'Usuário atualizado.' : 'Novo usuário criado.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Ops! Atenção',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Get.back(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Entendi'),
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
    // Usamos MediaQuery aqui para evitar que o LayoutBuilder re-dispare builds desnecessários
    final width = MediaQuery.of(context).size.width;

    if (width > 900) {
      return AccessFormDesktopView(acesso: widget.acesso);
    }
    return _buildMobileView(context);
  }

  Widget _buildMobileView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF8F9FC),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuário' : 'Novo Usuário',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildMobileStepIndicator(theme),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 40 + bottomPadding),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildCurrentMobileStep(theme),
                          ),
                          const SizedBox(height: 24),
                          _buildWebFlowButtons(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStepIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepDot(0, 'Identidade'),
          _stepLine(0),
          _stepDot(1, 'Permissões'),
        ],
      ),
    );
  }

  Widget _stepDot(int index, String label) {
    bool isActive = _currentMobileStep == index;
    bool isDone = _currentMobileStep > index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color color = isActive || isDone
        ? theme.primaryColor
        : (isDark ? Colors.white24 : Colors.black12);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: (isActive || isDone) ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text('${index + 1}',
                    style: TextStyle(
                        color: (isActive || isDone) ? Colors.white : color,
                        fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _stepLine(int index) {
    bool isDone = _currentMobileStep > index;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      color: isDone ? Theme.of(context).primaryColor : Colors.black12,
    );
  }

  Widget _buildCurrentMobileStep(ThemeData theme) {
    if (_currentMobileStep == 0) {
      return Column(
        key: const ValueKey(0),
        children: [
          _buildCard(theme,
              title: 'Informações Pessoais',
              icon: Icons.person_outline,
              children: [
                _buildTextField(nomeController, 'Nome Completo', Icons.person,
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                const SizedBox(height: 16),
                _buildTextField(
                    emailController, 'E-mail Corporativo', Icons.email,
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            cpfController, 'CPF', Icons.fingerprint,
                            formatter: cpfFormatter,
                            inputType: TextInputType.number,
                            validator: (v) =>
                                v!.isEmpty ? 'Obrigatório' : null)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildTextField(
                            telefoneController, 'Celular', Icons.phone_android,
                            formatter: telefoneFormatter,
                            inputType: TextInputType.phone,
                            validator: (v) =>
                                v!.isEmpty ? 'Obrigatório' : null)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(enderecoController, 'Endereço Residencial',
                    Icons.location_on_outlined),
              ]),
        ],
      );
    } else {
      return Column(
        key: const ValueKey(1),
        children: [
          _buildCard(theme,
              title: 'Controle de Acesso',
              icon: Icons.security_rounded,
              children: [
                _buildDropdown(
                    'Função do Usuário',
                    funcao,
                    _controller.getFuncoes().map((f) => f.nome).toList(),
                    (v) => setState(() => funcao = v),
                    Icons.admin_panel_settings),
                if (isEditing) ...[
                  const SizedBox(height: 20),
                  _buildDropdown(
                      'Status da Conta',
                      status,
                      ['Ativo', 'Inativo'],
                      (v) => setState(() => status = v),
                      Icons.info_outline),
                ],
              ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_reset_rounded,
                    color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Segurança',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                          !isEditing
                              ? 'Novos usuários recebem a senha padrão: 123456'
                              : 'Status de pendência de senha mantido.',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: theme.hintColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildWebFlowButtons(ThemeData theme) {
    bool isLast = _currentMobileStep == 1;
    return Row(
      children: [
        if (_currentMobileStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentMobileStep--),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Anterior'),
            ),
          ),
        if (_currentMobileStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Obx(() => FilledButton(
                onPressed: isLast && !_controller.isLoading
                    ? _submitForm
                    : isLast
                        ? null
                        : () => setState(() => _currentMobileStep++),
                style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _controller.isLoading && isLast
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isLast
                        ? (isEditing ? 'Salvar Alterações' : 'Criar Usuário')
                        : 'Próximo Passo'),
              )),
        ),
      ],
    );
  }

  Widget _buildCard(ThemeData theme,
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {String? Function(String?)? validator,
      MaskTextInputFormatter? formatter,
      TextInputType? inputType}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: formatter != null ? [formatter] : [],
      keyboardType: inputType,
      decoration: _buildInputDecoration(label, icon),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged, IconData icon) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: _buildInputDecoration(label, icon),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: theme.primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
