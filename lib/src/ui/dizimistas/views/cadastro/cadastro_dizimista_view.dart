import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../models/dizimista_model.dart';
import '../../controllers/dizimista_controller.dart';
import './cadastro_dizimista_desktop_view.dart';

class CadastroDizimistaView extends StatefulWidget {
  final Dizimista? dizimista;

  const CadastroDizimistaView({Key? key, this.dizimista}) : super(key: key);

  @override
  State<CadastroDizimistaView> createState() => _CadastroDizimistaViewState();
}

class _CadastroDizimistaViewState extends State<CadastroDizimistaView> {
  final _formKey = GlobalKey<FormState>();

  final DizimistaController _dizimistaController =
      Get.find<DizimistaController>();

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
  late MaskTextInputFormatter cpfFormatter;
  late MaskTextInputFormatter telefoneFormatter;

  DateTime? dataNascimento;
  String? sexo;
  String? estadoCivil;
  String? status;
  DateTime? dataCasamento;
  DateTime? dataNascimentoConjugue;
  int _currentMobileStep = 0;

  bool get isEditing => widget.dizimista != null;

  @override
  void initState() {
    super.initState();

    cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
    telefoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');

    _initializeControllers();
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
      sexo = (d?.sexo != null && d!.sexo!.isNotEmpty) ? d.sexo : null;
      estadoCivil = (d?.estadoCivil != null && d!.estadoCivil!.isNotEmpty)
          ? d.estadoCivil
          : null;
      status = (d?.status != null && d!.status.isNotEmpty) ? d.status : 'Ativo';
      dataCasamento = d?.dataCasamento;
      dataNascimentoConjugue = d?.dataNascimentoConjugue;
    } else {
      status = 'Ativo';
    }
  }

  @override
  void dispose() {
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

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cpfSemMascara = cpfFormatter.unmaskText(cpfController.text);
      final telefoneSemMascara =
          telefoneFormatter.unmaskText(telefoneController.text);

      final dizimista = Dizimista(
        id: widget.dizimista?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        numeroRegistro: numeroRegistroController.text,
        nome: nomeController.text,
        cpf: cpfSemMascara,
        dataNascimento: dataNascimento,
        sexo: sexo,
        telefone: telefoneSemMascara,
        email: emailController.text.isNotEmpty ? emailController.text : null,
        rua: ruaController.text.isNotEmpty ? ruaController.text : null,
        numero: numeroController.text.isNotEmpty ? numeroController.text : null,
        bairro: bairroController.text,
        cidade: cidadeController.text,
        estado: estadoController.text,
        cep: widget.dizimista?.cep,
        estadoCivil: estadoCivil,
        nomeConjugue: nomeConjugueController.text.isNotEmpty
            ? nomeConjugueController.text
            : null,
        dataCasamento: dataCasamento,
        dataNascimentoConjugue: dataNascimentoConjugue,
        observacoes: observacoesController.text.isNotEmpty
            ? observacoesController.text
            : null,
        status: status ?? 'Ativo',
        dataRegistro: widget.dizimista?.dataRegistro ?? DateTime.now(),
      );

      try {
        if (isEditing) {
          await _dizimistaController.updateDizimista(dizimista);
        } else {
          await _dizimistaController.addDizimista(dizimista);
        }
        Get.back();
        Get.snackbar(
          'Sucesso',
          isEditing ? 'Dados atualizados.' : 'Novo fiel registrado.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return CadastroDizimistaDesktopView(dizimista: widget.dizimista);
        }
        return _buildMobileView(context);
      },
    );
  }

  Widget _buildMobileView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    bool isWide = screenWidth > 700;

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF8F9FC),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Registro' : 'Novo Registro',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildMobileStepIndicator(theme),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 40 + bottomPadding),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildCurrentMobileStep(theme, isWide),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          _stepDot(0, 'Pessoal'),
          _stepLine(0),
          _stepDot(1, 'Endereço'),
          _stepLine(1),
          _stepDot(2, 'Adicional'),
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
        : (isDark
            ? Colors.white.withOpacity(0.3)
            : theme.colorScheme.onSurface.withOpacity(0.15));

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: (isActive || isDone) ? color : Colors.transparent,
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: (isActive || isDone)
                            ? Colors.white
                            : (isDark
                                ? Colors.white70
                                : theme.colorScheme.onSurface.withOpacity(0.4)),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? (isDark ? Colors.white : color)
                  : (isDark
                      ? Colors.white.withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine(int index) {
    bool isDone = _currentMobileStep > index;
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isDone
          ? Theme.of(context).primaryColor
          : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
    );
  }

  Widget _buildCurrentMobileStep(ThemeData theme, bool isWide) {
    switch (_currentMobileStep) {
      case 0:
        return Column(
          key: const ValueKey(0),
          children: [
            _buildSectionCard(
              theme,
              title: 'Identificação',
              icon: Icons.badge_outlined,
              children: [
                _ResponsiveField(
                  isWide: isWide,
                  flex: 1,
                  child: _buildTextField(
                    controller: numeroRegistroController,
                    label: 'Nº Registro Paroquial',
                    icon: Icons.numbers,
                  ),
                ),
                if (isEditing)
                  _ResponsiveField(
                    isWide: isWide,
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: status,
                      decoration: _buildInputDecoration(
                          theme, 'Status do Fiel', Icons.info_outline),
                      items: ['Ativo', 'Inativo', 'Afastado']
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => status = v),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              theme,
              title: 'Dados Pessoais',
              icon: Icons.person_outline,
              children: [
                _ResponsiveField(
                  isWide: isWide,
                  flex: 2,
                  child: _buildTextField(
                    controller: nomeController,
                    label: 'Nome Completo *',
                    icon: Icons.person,
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                ),
                _ResponsiveField(
                  isWide: isWide,
                  flex: 1,
                  child: _buildTextField(
                    controller: cpfController,
                    label: 'CPF',
                    icon: Icons.fingerprint,
                    formatter: cpfFormatter,
                    inputType: TextInputType.number,
                  ),
                ),
                _ResponsiveField(
                  isWide: isWide,
                  flex: 1,
                  child: _buildDatePath(
                    label: 'Data de Nascimento',
                    date: dataNascimento,
                    onTap: () => _pickDate(context, dataNascimento,
                        (d) => setState(() => dataNascimento = d)),
                    theme: theme,
                  ),
                ),
                _ResponsiveField(
                  isWide: isWide,
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: sexo,
                    decoration: _buildInputDecoration(theme, 'Sexo', Icons.wc),
                    items: ['Masculino', 'Feminino']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => sexo = v),
                  ),
                ),
              ],
            ),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          children: [
            _buildSectionCard(
              theme,
              title: 'Contatos',
              icon: Icons.contact_phone_outlined,
              children: [
                _ResponsiveField(
                  isWide: isWide,
                  flex: 1,
                  child: _buildTextField(
                    controller: telefoneController,
                    label: 'Celular / WhatsApp *',
                    icon: Icons.phone_android,
                    formatter: telefoneFormatter,
                    inputType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                ),
                _ResponsiveField(
                  isWide: isWide,
                  flex: 2,
                  child: _buildTextField(
                    controller: emailController,
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              theme,
              title: 'Endereço',
              icon: Icons.location_on_outlined,
              children: [
                _ResponsiveField(
                  isWide: isWide,
                  flex: 2,
                  child: _buildTextField(
                      controller: ruaController,
                      label: 'Rua / Logradouro',
                      icon: Icons.add_road),
                ),
                _ResponsiveField(
                  isWide: isWide,
                  flex: 1,
                  child: _buildTextField(
                      controller: numeroController,
                      label: 'Número',
                      icon: Icons.home_mini),
                ),
                _ResponsiveField(
                  isWide: isWide,
                  flex: 2,
                  child: _buildTextField(
                      controller: bairroController,
                      label: 'Bairro',
                      icon: Icons.location_city),
                ),
                _ResponsiveField(
                  isWide: isWide,
                  flex: 2,
                  child: _buildTextField(
                      controller: cidadeController,
                      label: 'Cidade',
                      icon: Icons.location_city),
                ),
                _ResponsiveField(
                  isWide: isWide,
                  flex: 1,
                  child: _buildTextField(
                      controller: estadoController,
                      label: 'UF',
                      icon: Icons.flag),
                ),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          children: [
            _buildSectionCard(
              theme,
              title: 'Dados Matrimoniais',
              icon: Icons.favorite_border,
              children: [
                _ResponsiveField(
                  isWide: isWide,
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: estadoCivil,
                    decoration: _buildInputDecoration(
                        theme, 'Estado Civil *', Icons.people_outline),
                    validator: (v) => v == null ? 'Obrigatório' : null,
                    items: ['Solteiro', 'Casado', 'Viúvo', 'Separado']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => estadoCivil = v),
                  ),
                ),
              ],
            ),
            if (estadoCivil == 'Casado') ...[
              const SizedBox(height: 12),
              _buildSectionCard(
                theme,
                title: 'Dados do Cônjuge',
                icon: Icons.people_outline,
                children: [
                  _ResponsiveField(
                    isWide: isWide,
                    flex: 2,
                    child: _buildTextField(
                        controller: nomeConjugueController,
                        label: 'Nome do Cônjuge *',
                        icon: Icons.person_add_alt,
                        validator: (v) =>
                            (estadoCivil == 'Casado' && (v?.isEmpty ?? true))
                                ? 'Obrigatório para casados'
                                : null),
                  ),
                  _ResponsiveField(
                    isWide: isWide,
                    flex: 1,
                    child: _buildDatePath(
                      label: 'Data Casamento *',
                      date: dataCasamento,
                      validator:
                          (estadoCivil == 'Casado' && dataCasamento == null)
                              ? 'Obrigatório'
                              : null,
                      onTap: () => _pickDate(context, dataCasamento,
                          (d) => setState(() => dataCasamento = d)),
                      theme: theme,
                    ),
                  ),
                  _ResponsiveField(
                    isWide: isWide,
                    flex: 1,
                    child: _buildDatePath(
                      label: 'Nasc. Cônjuge *',
                      date: dataNascimentoConjugue,
                      validator: (estadoCivil == 'Casado' &&
                              dataNascimentoConjugue == null)
                          ? 'Obrigatório'
                          : null,
                      onTap: () => _pickDate(context, dataNascimentoConjugue,
                          (d) => setState(() => dataNascimentoConjugue = d)),
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color:
                          theme.colorScheme.outlineVariant.withOpacity(0.5))),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outras Informações',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: observacoesController,
                      maxLines: 3,
                      decoration: _buildInputDecoration(
                              theme, 'Observações', Icons.notes)
                          .copyWith(alignLabelWithHint: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildWebFlowButtons(ThemeData theme) {
    bool isLastStep = _currentMobileStep == 2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          if (_currentMobileStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentMobileStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Anterior'),
              ),
            ),
          if (_currentMobileStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(() => FilledButton(
                  onPressed: _dizimistaController.isLoading
                      ? null
                      : () {
                          if (isLastStep) {
                            _submitForm();
                          } else {
                            setState(() => _currentMobileStep++);
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _dizimistaController.isLoading && isLastStep
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isLastStep ? 'Concluir Cadastro' : 'Próximo Passo'),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(ThemeData theme,
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 18,
                    color: theme.brightness == Brightness.dark
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.8)),
                const SizedBox(width: 8),
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
              ],
            ),
            const Divider(height: 16, thickness: 0.5),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? inputType,
    MaskTextInputFormatter? formatter,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: formatter != null ? [formatter] : [],
      validator: validator,
      decoration: _buildInputDecoration(Theme.of(context), label, icon),
    );
  }

  Widget _buildDatePath({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required ThemeData theme,
    String? validator,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: _formatDate(date)),
          validator: (_) => validator,
          decoration:
              _buildInputDecoration(theme, label, Icons.calendar_today_rounded),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate(BuildContext context, DateTime? initialDate,
      ValueChanged<DateTime> onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) onDateSelected(picked);
  }

  InputDecoration _buildInputDecoration(
      ThemeData theme, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon,
          size: 20,
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _ResponsiveField extends StatelessWidget {
  final bool isWide;
  final int flex;
  final Widget child;

  const _ResponsiveField({
    required this.isWide,
    required this.child,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!isWide) return SizedBox(width: double.infinity, child: child);
        double parentWidth = constraints.maxWidth;
        if (parentWidth == double.infinity) parentWidth = 600;
        double width;
        if (flex == 2) {
          width = (parentWidth / 2) - 9;
        } else {
          width = (parentWidth / 3) - 12;
          if (width < 180) width = (parentWidth / 2) - 9;
        }
        return SizedBox(width: width.clamp(150.0, parentWidth), child: child);
      },
    );
  }
}
