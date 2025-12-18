import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/dizimista_model.dart';

class DizimistaFormDialog extends StatefulWidget {
  final Dizimista? dizimista;
  final Function(Dizimista)? onSave;
  final String title;

  const DizimistaFormDialog({
    Key? key,
    this.dizimista,
    this.onSave,
    this.title = 'Novo Fiel',
  }) : super(key: key);

  @override
  State<DizimistaFormDialog> createState() => _DizimistaFormDialogState();
}

class _DizimistaFormDialogState extends State<DizimistaFormDialog> {
  // Controladores de texto
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

  // Formatters para máscaras
  late MaskTextInputFormatter cpfFormatter;
  late MaskTextInputFormatter telefoneFormatter;
  late MaskTextInputFormatter cepFormatter;

  // Estado para os campos não-texto
  DateTime? dataNascimento;
  String? sexo;
  String? estadoCivil;
  DateTime? dataCasamento;
  DateTime? dataNascimentoConjugue;
  bool consentimento = false;
  String selectedStatus = 'Ativo';

  @override
  void initState() {
    super.initState();

    // Inicializar formatters PRIMEIRO
    cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
    );
    telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );
    cepFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
    );

    // Inicializar controladores com valores formatados
    numeroRegistroController = TextEditingController(
      text: widget.dizimista?.numeroRegistro ?? '',
    );
    nomeController = TextEditingController(text: widget.dizimista?.nome ?? '');

    // Aplica máscara ao CPF se existir
    cpfController = TextEditingController(
      text: widget.dizimista?.cpf != null
          ? cpfFormatter.maskText(widget.dizimista!.cpf)
          : '',
    );

    // Aplica máscara ao Telefone se existir
    telefoneController = TextEditingController(
      text: widget.dizimista?.telefone != null
          ? telefoneFormatter.maskText(widget.dizimista!.telefone)
          : '',
    );

    emailController = TextEditingController(
      text: widget.dizimista?.email ?? '',
    );
    ruaController = TextEditingController(text: widget.dizimista?.rua ?? '');
    numeroController = TextEditingController(
      text: widget.dizimista?.numero ?? '',
    );
    bairroController = TextEditingController(
      text: widget.dizimista?.bairro ?? '',
    );
    cidadeController = TextEditingController(
      text: widget.dizimista?.cidade ?? '',
    );
    estadoController = TextEditingController(
      text: widget.dizimista?.estado ?? '',
    );

    // Aplica máscara ao CEP se existir
    cepController = TextEditingController(
      text: widget.dizimista?.cep != null
          ? cepFormatter.maskText(widget.dizimista!.cep!)
          : '',
    );

    nomeConjugueController = TextEditingController(
      text: widget.dizimista?.nomeConjugue ?? '',
    );
    observacoesController = TextEditingController(
      text: widget.dizimista?.observacoes ?? '',
    );

    // Carregar dados existentes se estiver editando
    if (widget.dizimista != null) {
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
    // Disposicao dos controladores
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    // inputDecoration seguindo padrão Material 3
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
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
      isDense: true, // Mantém compacto
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    final formContent = SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        // Adiciona padding na parte inferior para compensar o teclado.
        bottom: 40 + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número de Registro Paroquial
          TextField(
            controller: numeroRegistroController,
            decoration: inputDecoration.copyWith(
              labelText: 'Nº de Registro Paroquial *',
              hintText: 'Ex: 0001',
            ),
          ),
          const SizedBox(height: 16),

          // Dados Pessoais
          Text(
            'Dados Pessoais',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Nome Completo
          TextField(
            controller: nomeController,
            decoration: inputDecoration.copyWith(
              labelText: 'Nome Completo *',
              hintText: 'Ex: João da Silva',
            ),
          ),
          const SizedBox(height: 16),

          // CPF
          TextField(
            controller: cpfController,
            inputFormatters: [cpfFormatter],
            keyboardType: TextInputType.number,
            decoration: inputDecoration.copyWith(
              labelText: 'CPF *',
              hintText: '000.000.000-00',
            ),
          ),
          const SizedBox(height: 16),

          // Data de Nascimento
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: dataNascimento ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => dataNascimento = date);
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: TextEditingController(
                  text: dataNascimento != null
                      ? '${dataNascimento!.day.toString().padLeft(2, '0')}/${dataNascimento!.month.toString().padLeft(2, '0')}/${dataNascimento!.year}'
                      : '',
                ),
                decoration: inputDecoration.copyWith(
                  labelText: 'Data de Nascimento',
                  hintText: 'Selecione a data',
                  suffixIcon: const Icon(Icons.calendar_today_rounded),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sexo (Dropdown M3 Style)
          DropdownButtonFormField<String>(
            value: sexo,
            decoration: inputDecoration.copyWith(labelText: 'Sexo'),
            items: [
              'Masculino',
              'Feminino',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => sexo = v),
          ),
          const SizedBox(height: 24),

          // Contato
          Text(
            'Dados de Contato',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: telefoneController,
            inputFormatters: [telefoneFormatter],
            keyboardType: TextInputType.phone,
            decoration: inputDecoration.copyWith(
              labelText: 'Telefone / WhatsApp *',
              hintText: '(00) 00000-0000',
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: inputDecoration.copyWith(
              labelText: 'E-mail',
              hintText: 'exemplo@email.com',
            ),
          ),
          const SizedBox(height: 24),

          // Endereço
          Text(
            'Endereço',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: ruaController,
            decoration: inputDecoration.copyWith(labelText: 'Rua'),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: numeroController,
                  decoration: inputDecoration.copyWith(labelText: 'Número'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: bairroController,
                  decoration: inputDecoration.copyWith(labelText: 'Bairro *'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: cidadeController,
                  decoration: inputDecoration.copyWith(labelText: 'Cidade *'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: estadoController,
                  decoration: inputDecoration.copyWith(labelText: 'UF *'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: cepController,
            inputFormatters: [cepFormatter],
            keyboardType: TextInputType.number,
            decoration: inputDecoration.copyWith(labelText: 'CEP'),
          ),
          const SizedBox(height: 24),

          // Estado Civil e Conjuge
          DropdownButtonFormField<String>(
            value: estadoCivil,
            decoration: inputDecoration.copyWith(labelText: 'Estado Civil'),
            items: [
              'Solteiro',
              'Casado',
              'Viúvo',
              'Separado',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => estadoCivil = v),
          ),

          if (estadoCivil == 'Casado') ...[
            const SizedBox(height: 16),
            Text(
              'Dados do Cônjuge',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeConjugueController,
              decoration: inputDecoration.copyWith(
                labelText: 'Nome do Cônjuge',
              ),
            ),
            const SizedBox(height: 16),
            // Data de Casamento
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: dataCasamento ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    dataCasamento = date;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: dataCasamento != null
                        ? '${dataCasamento!.day.toString().padLeft(2, '0')}/${dataCasamento!.month.toString().padLeft(2, '0')}/${dataCasamento!.year}'
                        : '',
                  ),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Data de Casamento',
                    hintText: 'Selecione a data',
                    suffixIcon: const Icon(Icons.calendar_today_rounded),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Data de Nascimento do Cônjuge
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: dataNascimentoConjugue ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    dataNascimentoConjugue = date;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: dataNascimentoConjugue != null
                        ? '${dataNascimentoConjugue!.day.toString().padLeft(2, '0')}/${dataNascimentoConjugue!.month.toString().padLeft(2, '0')}/${dataNascimentoConjugue!.year}'
                        : '',
                  ),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Data de Nascimento do Cônjuge',
                    hintText: 'Selecione a data',
                    suffixIcon: const Icon(Icons.calendar_today_rounded),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          TextField(
            controller: observacoesController,
            maxLines: 3,
            decoration: inputDecoration.copyWith(labelText: 'Observações'),
          ),

          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Autorizo o uso dos meus dados',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            subtitle: Text(
              'Para fins pastorais e administrativos',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            value: consentimento,
            onChanged: (v) => setState(() => consentimento = v),
          ),

          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: inputDecoration.copyWith(labelText: 'Status'),
            items: [
              'Ativo',
              'Afastado',
              'Inativo',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => selectedStatus = v);
            },
          ),
          if (!isMobile && bottomPadding > 0) const SizedBox(height: 20),
        ],
      ),
    );

    // VERSÃO MOBILE: TELA CHEIA
    if (isMobile) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Dialog.fullscreen(
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            // Impede o Scaffold de redimensionar, a rolagem é controlada manualmente.
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(widget.title),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                TextButton(
                  onPressed: _submitForm,
                  child: const Text('Salvar'),
                ),
              ],
            ),
            body: formContent,
          ),
        ),
      );
    }

    // VERSÃO DESKTOP: MODAL
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            ),
            Expanded(child: formContent),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submitForm,
                    child: Text(
                      widget.dizimista != null
                          ? 'Salvar Alterações'
                          : 'Salvar Fiel',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    // Validação dos campos obrigatórios
    if (nomeController.text.isEmpty ||
        cpfController.text.isEmpty ||
        telefoneController.text.isEmpty ||
        bairroController.text.isEmpty ||
        cidadeController.text.isEmpty ||
        estadoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Preencha os campos obrigatórios: Nome, CPF, Telefone, Bairro, Cidade e Estado',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Remove as máscaras antes de salvar
    final cpfSemMascara = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
    final telefoneSemMascara = telefoneController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final cepSemMascara = cepController.text.replaceAll(RegExp(r'[^\d]'), '');

    final novoDizimista = Dizimista(
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
      cep: cepSemMascara.isNotEmpty ? cepSemMascara : null,
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
      status: selectedStatus,
      dataRegistro: widget.dizimista?.dataRegistro ?? DateTime.now(),
    );

    if (widget.onSave != null) {
      widget.onSave!(novoDizimista);
    }
  }
}
