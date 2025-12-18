import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../models/dizimista_model.dart';
import '../../controllers/dizimista_controller.dart';

class EditarDizimistaView extends StatefulWidget {
  final Dizimista? dizimista;

  const EditarDizimistaView({Key? key, this.dizimista}) : super(key: key);

  @override
  State<EditarDizimistaView> createState() => _EditarDizimistaViewState();
}

class _EditarDizimistaViewState extends State<EditarDizimistaView> {
  final _formKey = GlobalKey<FormState>();
  final DizimistaController _dizimistaController = Get.find();

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
  late TextEditingController cepController;
  late TextEditingController nomeConjugueController;
  late TextEditingController observacoesController;

  late MaskTextInputFormatter cpfFormatter;
  late MaskTextInputFormatter telefoneFormatter;
  late MaskTextInputFormatter cepFormatter;

  DateTime? dataNascimento;
  String? sexo;
  String? estadoCivil;
  DateTime? dataCasamento;
  DateTime? dataNascimentoConjugue;
  bool consentimento = false;
  String selectedStatus = 'Ativo';

  bool get isEditing => widget.dizimista != null;

  @override
  void initState() {
    super.initState();

    cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##');
    telefoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####');
    cepFormatter = MaskTextInputFormatter(mask: '#####-###');

    numeroRegistroController = TextEditingController(text: widget.dizimista?.numeroRegistro ?? '');
    nomeController = TextEditingController(text: widget.dizimista?.nome ?? '');
    cpfController = TextEditingController(text: widget.dizimista != null ? cpfFormatter.maskText(widget.dizimista!.cpf) : '');
    telefoneController = TextEditingController(text: widget.dizimista != null ? telefoneFormatter.maskText(widget.dizimista!.telefone) : '');
    emailController = TextEditingController(text: widget.dizimista?.email ?? '');
    ruaController = TextEditingController(text: widget.dizimista?.rua ?? '');
    numeroController = TextEditingController(text: widget.dizimista?.numero ?? '');
    bairroController = TextEditingController(text: widget.dizimista?.bairro ?? '');
    cidadeController = TextEditingController(text: widget.dizimista?.cidade ?? '');
    estadoController = TextEditingController(text: widget.dizimista?.estado ?? '');
    cepController = TextEditingController(text: widget.dizimista?.cep != null ? cepFormatter.maskText(widget.dizimista!.cep!) : '');
    nomeConjugueController = TextEditingController(text: widget.dizimista?.nomeConjugue ?? '');
    observacoesController = TextEditingController(text: widget.dizimista?.observacoes ?? '');

    if (isEditing) {
      dataNascimento = widget.dizimista?.dataNascimento;
      sexo = widget.dizimista?.sexo;
      estadoCivil = widget.dizimista?.estadoCivil;
      dataCasamento = widget.dizimista?.dataCasamento;
      dataNascimentoConjugue = widget.dizimista?.dataNascimentoConjugue;
      consentimento = widget.dizimista?.consentimento ?? false;
      selectedStatus = widget.dizimista?.status ?? 'Ativo';
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
    cepController.dispose();
    nomeConjugueController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cpfSemMascara = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
      final telefoneSemMascara = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      final cepSemMascara = cepController.text.replaceAll(RegExp(r'[^\d]'), '');

      final dizimista = Dizimista(
        id: widget.dizimista?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
        cep: cepSemMascara.isNotEmpty ? cepSemMascara : null,
        estadoCivil: estadoCivil,
        nomeConjugue: nomeConjugueController.text.isNotEmpty ? nomeConjugueController.text : null,
        dataCasamento: dataCasamento,
        dataNascimentoConjugue: dataNascimentoConjugue,
        observacoes: observacoesController.text.isNotEmpty ? observacoesController.text : null,
        consentimento: consentimento,
        status: selectedStatus,
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
          'Sucesso!',
          isEditing ? 'Fiel atualizado com sucesso.' : 'Fiel cadastrado com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Erro',
          'Ocorreu um erro ao salvar o fiel: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecoration = InputDecoration(
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Fiel' : 'Novo Fiel'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton(
              onPressed: _submitForm,
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // MELHORIA: Fecha o teclado ao arrastar a lista
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: numeroRegistroController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Nº de Registro Paroquial',
                ),
              ),
              const SizedBox(height: 16),
              Text('Dados Pessoais', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: nomeController,
                decoration: inputDecoration.copyWith(labelText: 'Nome Completo *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cpfController,
                inputFormatters: [cpfFormatter],
                keyboardType: TextInputType.number,
                decoration: inputDecoration.copyWith(labelText: 'CPF *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: dataNascimento ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                  if (date != null) setState(() => dataNascimento = date);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: dataNascimento != null ? '${dataNascimento!.day.toString().padLeft(2, '0')}/${dataNascimento!.month.toString().padLeft(2, '0')}/${dataNascimento!.year}' : ''),
                    decoration: inputDecoration.copyWith(labelText: 'Data de Nascimento', suffixIcon: const Icon(Icons.calendar_today_rounded)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: sexo,
                decoration: inputDecoration.copyWith(labelText: 'Sexo'),
                items: ['Masculino', 'Feminino'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => sexo = v),
              ),
              const SizedBox(height: 24),
              Text('Dados de Contato', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefoneController,
                inputFormatters: [telefoneFormatter],
                keyboardType: TextInputType.phone,
                decoration: inputDecoration.copyWith(labelText: 'Telefone / WhatsApp *'),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: inputDecoration.copyWith(labelText: 'E-mail'),
              ),
              const SizedBox(height: 24),
              Text('Endereço', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 16),
              TextFormField(controller: ruaController, decoration: inputDecoration.copyWith(labelText: 'Rua')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 1, child: TextFormField(controller: numeroController, decoration: inputDecoration.copyWith(labelText: 'Número'))),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: TextFormField(controller: bairroController, decoration: inputDecoration.copyWith(labelText: 'Bairro *'), validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 2, child: TextFormField(controller: cidadeController, decoration: inputDecoration.copyWith(labelText: 'Cidade *'), validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: estadoController, decoration: inputDecoration.copyWith(labelText: 'UF *'), validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(controller: cepController, inputFormatters: [cepFormatter], keyboardType: TextInputType.number, decoration: inputDecoration.copyWith(labelText: 'CEP')),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: estadoCivil,
                decoration: inputDecoration.copyWith(labelText: 'Estado Civil'),
                items: ['Solteiro', 'Casado', 'Viúvo', 'Separado'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => estadoCivil = v),
              ),
              if (estadoCivil == 'Casado') ...[
                const SizedBox(height: 16),
                Text('Dados do Cônjuge', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 16),
                TextFormField(controller: nomeConjugueController, decoration: inputDecoration.copyWith(labelText: 'Nome do Cônjuge')),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: dataCasamento ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                    if (date != null) setState(() => dataCasamento = date);
                  },
                  child: AbsorbPointer(child: TextFormField(controller: TextEditingController(text: dataCasamento != null ? '${dataCasamento!.day.toString().padLeft(2, '0')}/${dataCasamento!.month.toString().padLeft(2, '0')}/${dataCasamento!.year}' : ''), decoration: inputDecoration.copyWith(labelText: 'Data de Casamento', suffixIcon: const Icon(Icons.calendar_today_rounded)))),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: dataNascimentoConjugue ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                    if (date != null) setState(() => dataNascimentoConjugue = date);
                  },
                  child: AbsorbPointer(child: TextFormField(controller: TextEditingController(text: dataNascimentoConjugue != null ? '${dataNascimentoConjugue!.day.toString().padLeft(2, '0')}/${dataNascimentoConjugue!.month.toString().padLeft(2, '0')}/${dataNascimentoConjugue!.year}' : ''), decoration: inputDecoration.copyWith(labelText: 'Data de Nascimento do Cônjuge', suffixIcon: const Icon(Icons.calendar_today_rounded)))),
                ),
              ],
              const SizedBox(height: 24),

              // MELHORIA: Campo Observações com scrollPadding para não ficar colado no teclado
              TextFormField(
                controller: observacoesController,
                maxLines: 3,
                scrollPadding: const EdgeInsets.only(bottom: 150),
                decoration: inputDecoration.copyWith(labelText: 'Observações'),
              ),

              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('Autorizo o uso dos meus dados', style: GoogleFonts.inter(fontSize: 14)),
                subtitle: Text('Para fins pastorais e administrativos', style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                contentPadding: EdgeInsets.zero,
                value: consentimento,
                onChanged: (v) => setState(() => consentimento = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: inputDecoration.copyWith(labelText: 'Status'),
                items: ['Ativo', 'Afastado', 'Inativo'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedStatus = v);
                },
              ),

              // MELHORIA: Espaço extra no fim para permitir rolagem confortável
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}