import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../models/dizimista_model.dart';
import '../../controllers/dizimista_controller.dart';

class CadastroDizimistaDesktopView extends StatefulWidget {
  final Dizimista? dizimista;

  const CadastroDizimistaDesktopView({Key? key, this.dizimista})
      : super(key: key);

  @override
  State<CadastroDizimistaDesktopView> createState() =>
      _CadastroDizimistaDesktopViewState();
}

class _CadastroDizimistaDesktopViewState
    extends State<CadastroDizimistaDesktopView> {
  final _formKey = GlobalKey<FormState>();
  final DizimistaController _controller = Get.find<DizimistaController>();
  final ScrollController _scrollController = ScrollController();

  // Controllers
  late TextEditingController numeroRegistroController;
  late TextEditingController nomeController;
  late TextEditingController cpfController;
  late TextEditingController telefoneController;
  late TextEditingController emailController;
  late TextEditingController ruaController;
  late TextEditingController numeroController;
  late TextEditingController bairroController;
  late TextEditingController cidadeController;
  late TextEditingController estadoController;
  late TextEditingController nomeConjugueController;
  late TextEditingController observacoesController;

  // Formatters
  final cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
  final telefoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');

  // State Variables
  DateTime? dataNascimento;
  String? sexo;
  String? estadoCivil;
  DateTime? dataCasamento;
  DateTime? dataNascimentoConjugue;
  String? status;
  bool consentimento = false;
  int activeSection = 0;

  bool get isEditing => widget.dizimista != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _scrollController.addListener(_onScroll);
  }

  void _initializeControllers() {
    final d = widget.dizimista;
    numeroRegistroController =
        TextEditingController(text: d?.numeroRegistro ?? '');
    nomeController = TextEditingController(text: d?.nome ?? '');
    cpfController = TextEditingController(
        text: d != null ? cpfFormatter.maskText(d.cpf) : '');
    telefoneController = TextEditingController(
        text: d != null ? telefoneFormatter.maskText(d.telefone) : '');
    emailController = TextEditingController(text: d?.email ?? '');
    ruaController = TextEditingController(text: d?.rua ?? '');
    numeroController = TextEditingController(text: d?.numero ?? '');
    bairroController = TextEditingController(text: d?.bairro ?? '');
    cidadeController = TextEditingController(text: d?.cidade ?? '');
    estadoController = TextEditingController(text: d?.estado ?? '');
    nomeConjugueController = TextEditingController(text: d?.nomeConjugue ?? '');
    observacoesController = TextEditingController(text: d?.observacoes ?? '');

    if (isEditing) {
      dataNascimento = d?.dataNascimento;
      sexo = d?.sexo;
      estadoCivil = d?.estadoCivil;
      dataCasamento = d?.dataCasamento;
      dataNascimentoConjugue = d?.dataNascimentoConjugue;
      status = (d?.status != null && d!.status.isNotEmpty) ? d.status : 'Ativo';
      consentimento = d?.consentimento ?? false;
    } else {
      status = 'Ativo';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    numeroRegistroController.dispose();
    nomeController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    nomeConjugueController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Logic to update activeSection based on scroll position could be added here
    // for a truly "spy" scroll effect.
  }

  void _scrollToSection(int index) {
    setState(() => activeSection = index);
    // Rough estimation of section heights
    double offset = index * 400.0;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!consentimento) {
        _showErrorDialog(
            'Para realizar o cadastro, é necessário autorizar o consentimento de dados.');
        return;
      }
      final dizimista = Dizimista(
        id: widget.dizimista?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        numeroRegistro: numeroRegistroController.text,
        nome: nomeController.text,
        cpf: cpfFormatter.unmaskText(cpfController.text),
        dataNascimento: dataNascimento,
        sexo: sexo,
        telefone: telefoneFormatter.unmaskText(telefoneController.text),
        email: emailController.text.isNotEmpty ? emailController.text : null,
        rua: ruaController.text.isNotEmpty ? ruaController.text : null,
        numero: numeroController.text.isNotEmpty ? numeroController.text : null,
        bairro: bairroController.text,
        cidade: cidadeController.text,
        estado: estadoController.text,
        cep: null,
        estadoCivil: estadoCivil,
        nomeConjugue: nomeConjugueController.text.isNotEmpty
            ? nomeConjugueController.text
            : null,
        dataCasamento: dataCasamento,
        dataNascimentoConjugue: dataNascimentoConjugue,
        observacoes: observacoesController.text.isNotEmpty
            ? observacoesController.text
            : null,
        consentimento: consentimento,
        status: status ?? 'Ativo',
        dataRegistro: widget.dizimista?.dataRegistro ?? DateTime.now(),
      );

      try {
        if (isEditing) {
          await _controller.updateDizimista(dizimista);
        } else {
          await _controller.addDizimista(dizimista);
        }
        Get.back();
        Get.snackbar(
          'Sucesso',
          isEditing
              ? 'Dados atualizados com sucesso.'
              : 'Novo fiel cadastrado com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(24),
          borderRadius: 16,
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
          width: 400,
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
                'Atenção',
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
                  fontSize: 16,
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
                  child: Text('Entendi',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 16)),
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
    final backgroundColor =
        isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          // SIDEBAR NAVIGATION
          _buildSidebar(theme, isDark),

          // MAIN CONTENT
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
                        // FORM AREA
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(32, 24, 16, 120),
                            child: Column(
                              children: [
                                _buildSection(
                                  id: 0,
                                  title: 'Identificação',
                                  icon: Icons.badge_outlined,
                                  theme: theme,
                                  children: [
                                    _buildRow([
                                      _buildTextField(
                                        controller: numeroRegistroController,
                                        label: 'Nº Registro Paroquial',
                                        icon: Icons.numbers_rounded,
                                        flex: 1,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obrigatório' : null,
                                      ),
                                      if (isEditing)
                                        _buildDropdownField(
                                          label: 'Status do Fiel',
                                          value: status,
                                          items: [
                                            'Ativo',
                                            'Inativo',
                                            'Afastado'
                                          ],
                                          onChanged: (v) =>
                                              setState(() => status = v),
                                          icon: Icons.info_outline_rounded,
                                          flex: 1,
                                        ),
                                    ]),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildSection(
                                  id: 1,
                                  title: 'Dados Pessoais',
                                  icon: Icons.person_outline_rounded,
                                  theme: theme,
                                  children: [
                                    _buildRow([
                                      _buildTextField(
                                        controller: nomeController,
                                        label: 'Nome Completo',
                                        icon: Icons.person_rounded,
                                        flex: 2,
                                        validator: (v) => v!.isEmpty
                                            ? 'Campo obrigatório'
                                            : null,
                                      ),
                                      _buildTextField(
                                        controller: cpfController,
                                        label: 'CPF',
                                        icon: Icons.fingerprint_rounded,
                                        formatter: cpfFormatter,
                                        inputType: TextInputType.number,
                                        flex: 1,
                                        validator: (v) => v!.isEmpty
                                            ? 'Campo obrigatório'
                                            : null,
                                      ),
                                    ]),
                                    const SizedBox(height: 16),
                                    _buildRow([
                                      _buildDateField(
                                        label: 'Data de Nascimento',
                                        date: dataNascimento,
                                        validator: dataNascimento == null
                                            ? 'Obrigatório'
                                            : null,
                                        onTap: () => _pickDate(
                                            dataNascimento,
                                            (d) => setState(
                                                () => dataNascimento = d)),
                                        theme: theme,
                                        flex: 1,
                                      ),
                                      _buildDropdownField(
                                        label: 'Sexo',
                                        value: sexo,
                                        items: ['Masculino', 'Feminino'],
                                        onChanged: (v) =>
                                            setState(() => sexo = v),
                                        icon: Icons.wc_rounded,
                                        flex: 1,
                                      ),
                                      _buildDropdownField(
                                        label: 'Estado Civil',
                                        value: estadoCivil,
                                        validator: (v) =>
                                            v == null ? 'Obrigatório' : null,
                                        items: [
                                          'Solteiro',
                                          'Casado',
                                          'Viúvo',
                                          'Separado'
                                        ],
                                        onChanged: (v) =>
                                            setState(() => estadoCivil = v),
                                        icon: Icons.favorite_rounded,
                                        flex: 1,
                                      ),
                                    ]),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildSection(
                                  id: 2,
                                  title: 'Contato & Endereço',
                                  icon: Icons.location_on_outlined,
                                  theme: theme,
                                  children: [
                                    _buildRow([
                                      _buildTextField(
                                        controller: telefoneController,
                                        label: 'Celular / WhatsApp',
                                        icon: Icons.phone_iphone_rounded,
                                        formatter: telefoneFormatter,
                                        inputType: TextInputType.phone,
                                        flex: 1,
                                        validator: (v) => v!.isEmpty
                                            ? 'Campo obrigatório'
                                            : null,
                                      ),
                                      _buildTextField(
                                        controller: emailController,
                                        label: 'E-mail',
                                        icon: Icons.alternate_email_rounded,
                                        inputType: TextInputType.emailAddress,
                                        flex: 2,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Obrigatório' : null,
                                      ),
                                    ]),
                                    const SizedBox(height: 16),
                                    _buildRow([
                                      _buildTextField(
                                        controller: ruaController,
                                        label: 'Rua / Logradouro',
                                        icon: Icons.add_road_rounded,
                                        flex: 3,
                                      ),
                                      _buildTextField(
                                        controller: numeroController,
                                        label: 'Número',
                                        icon: Icons.home_rounded,
                                        flex: 1,
                                      ),
                                    ]),
                                    const SizedBox(height: 16),
                                    _buildRow([
                                      _buildTextField(
                                        controller: bairroController,
                                        label: 'Bairro',
                                        icon: Icons.holiday_village_rounded,
                                        flex: 2,
                                      ),
                                      _buildTextField(
                                        controller: cidadeController,
                                        label: 'Cidade',
                                        icon: Icons.location_city_rounded,
                                        flex: 2,
                                      ),
                                      _buildTextField(
                                        controller: estadoController,
                                        label: 'UF',
                                        icon: Icons.flag_rounded,
                                        flex: 1,
                                      ),
                                    ]),
                                  ],
                                ),
                                if (estadoCivil == 'Casado') ...[
                                  const SizedBox(height: 24),
                                  _buildSection(
                                    id: 3,
                                    title: 'Dados do Cônjuge',
                                    icon: Icons.people_outline_rounded,
                                    theme: theme,
                                    children: [
                                      _buildTextField(
                                        controller: nomeConjugueController,
                                        label: 'Nome do Cônjuge',
                                        icon: Icons.person_add_rounded,
                                        validator: (v) =>
                                            (estadoCivil == 'Casado' &&
                                                    (v?.isEmpty ?? true))
                                                ? 'Obrigatório'
                                                : null,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildRow([
                                        _buildDateField(
                                          label: 'Data Casamento',
                                          date: dataCasamento,
                                          validator: (estadoCivil == 'Casado' &&
                                                  dataCasamento == null)
                                              ? 'Obrigatório'
                                              : null,
                                          onTap: () => _pickDate(
                                              dataCasamento,
                                              (d) => setState(
                                                  () => dataCasamento = d)),
                                          theme: theme,
                                          flex: 1,
                                        ),
                                        _buildDateField(
                                          label: 'Nasc. Cônjuge',
                                          date: dataNascimentoConjugue,
                                          validator: (estadoCivil == 'Casado' &&
                                                  dataNascimentoConjugue ==
                                                      null)
                                              ? 'Obrigatório'
                                              : null,
                                          onTap: () => _pickDate(
                                              dataNascimentoConjugue,
                                              (d) => setState(() =>
                                                  dataNascimentoConjugue = d)),
                                          theme: theme,
                                          flex: 1,
                                        ),
                                      ]),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                                _buildSection(
                                  id: 4,
                                  title: 'Informações Adicionais',
                                  icon: Icons.note_add_outlined,
                                  theme: theme,
                                  children: [
                                    TextFormField(
                                      controller: observacoesController,
                                      maxLines: 4,
                                      decoration: _buildInputDecoration(
                                              theme,
                                              'Observações / Notas Pastorais',
                                              Icons.notes_rounded)
                                          .copyWith(
                                        alignLabelWithHint: true,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor
                                            .withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: theme.primaryColor
                                                .withOpacity(0.1)),
                                      ),
                                      child: SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                            'Consentimento de Dados (LGPD)',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w600)),
                                        subtitle: const Text(
                                            'Autorizo o tratamento dos dados para fins eclesiásticos conforme a política de privacidade.'),
                                        value: consentimento,
                                        onChanged: (v) =>
                                            setState(() => consentimento = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // SUMMARY PREVIEW
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
                  child: Icon(Icons.person_add_rounded,
                      color: theme.primaryColor, size: 35),
                ),
                const SizedBox(height: 16),
                Text(
                  isEditing ? 'Atualizar Fiel' : 'Novo Cadastro',
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Preencha as etapas do registro',
                  style: TextStyle(color: theme.hintColor, fontSize: 13),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSidebarItem(0, 'Identificação', Icons.badge_outlined, theme),
          _buildSidebarItem(
              1, 'Dados Pessoais', Icons.person_outline_rounded, theme),
          _buildSidebarItem(
              2, 'Contato & Endereço', Icons.location_on_outlined, theme),
          if (estadoCivil == 'Casado')
            _buildSidebarItem(
                3, 'Dados do Cônjuge', Icons.favorite_outline_rounded, theme),
          _buildSidebarItem(
              4, 'Finalização', Icons.check_circle_outline_rounded, theme),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      int index, String label, IconData icon, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark
        ? theme.colorScheme.primary
        : theme.colorScheme.primary.withOpacity(0.8);
    bool isActive = activeSection == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _scrollToSection(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color:
                    isActive ? theme.colorScheme.primary : Colors.transparent,
                width: 4,
              ),
            ),
            color: isActive
                ? theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? iconColor : theme.hintColor.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isActive ? theme.colorScheme.primary : theme.hintColor,
                ),
              ),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            isEditing
                ? 'Cadastro / Editar Registro'
                : 'Cadastro / Novo Registro',
            style: GoogleFonts.outfit(fontSize: 14, color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required int id,
    required String title,
    required IconData icon,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark
        ? theme.colorScheme.primary
        : theme.colorScheme.primary.withOpacity(0.8);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
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
                  color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Text(title,
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map((w) => Expanded(
              child:
                  Padding(padding: const EdgeInsets.only(right: 16), child: w)))
          .toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int flex = 1,
    TextInputType? inputType,
    MaskTextInputFormatter? formatter,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: formatter != null ? [formatter] : [],
      validator: validator,
      style: GoogleFonts.inter(fontSize: 15),
      onChanged: (v) => setState(() {}),
      decoration: _buildInputDecoration(Theme.of(context), label, icon),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    String? Function(String?)? validator,
    int flex = 1,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: _buildInputDecoration(Theme.of(context), label, icon),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required ThemeData theme,
    String? validator,
    int flex = 1,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: date != null
                ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                : '',
          ),
          validator: (_) => validator,
          decoration:
              _buildInputDecoration(theme, label, Icons.calendar_today_rounded),
        ),
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
      floatingLabelStyle:
          TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 2),
      ),
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? Colors.white.withOpacity(0.03)
          : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildPreviewCard(ThemeData theme, bool isDark) {
    return Container(
      width: 400,
      padding: const EdgeInsets.fromLTRB(16, 24, 32, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                    : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: theme.primaryColor.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logo.jpg',
                        height: 40,
                        errorBuilder: (_, __, ___) => Icon(Icons.church_rounded,
                            color: Colors.white.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 48),
                Text(
                  nomeController.text.isEmpty
                      ? 'NOME DO FIÉL'
                      : nomeController.text.toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('REGISTRO:',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(
                        numeroRegistroController.text.isEmpty
                            ? '---'
                            : numeroRegistroController.text,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPreviewInfo(
                        'CPF',
                        cpfController.text.isEmpty
                            ? '000.000.000-00'
                            : cpfController.text),
                    _buildPreviewInfo(
                        'TELEFONE',
                        telefoneController.text.isEmpty
                            ? '(00) 00000-0000'
                            : telefoneController.text),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // TIPS CARD
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: theme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text('Dica de Preenchimento',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Mantenha os dados de endereço atualizados para o envio de correspondências paroquiais e informativos do dízimo.',
                  style: TextStyle(fontSize: 13, color: theme.hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 9,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBottomActions(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border:
            Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 16),
          Obx(() => ElevatedButton.icon(
                onPressed: _controller.isLoading ? null : _submitForm,
                icon: _controller.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label:
                    Text(isEditing ? 'Salvar Alterações' : 'Concluir Cadastro'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: theme.primaryColor.withOpacity(0.4),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _pickDate(
      DateTime? initial, Function(DateTime) onConfirm) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) onConfirm(date);
  }
}
