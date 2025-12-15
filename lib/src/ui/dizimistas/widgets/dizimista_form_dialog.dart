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
    
    // Inicializar controladores
    numeroRegistroController = TextEditingController(text: widget.dizimista?.numeroRegistro ?? '');
    nomeController = TextEditingController(text: widget.dizimista?.nome ?? '');
    cpfController = TextEditingController(text: widget.dizimista?.cpf ?? '');
    telefoneController = TextEditingController(text: widget.dizimista?.telefone ?? '');
    emailController = TextEditingController(text: widget.dizimista?.email ?? '');
    ruaController = TextEditingController(text: widget.dizimista?.rua ?? '');
    numeroController = TextEditingController(text: widget.dizimista?.numero ?? '');
    bairroController = TextEditingController(text: widget.dizimista?.bairro ?? '');
    cidadeController = TextEditingController(text: widget.dizimista?.cidade ?? '');
    estadoController = TextEditingController(text: widget.dizimista?.estado ?? '');
    cepController = TextEditingController(text: widget.dizimista?.cep ?? '');
    nomeConjugueController = TextEditingController(text: widget.dizimista?.nomeConjugue ?? '');
    observacoesController = TextEditingController(text: widget.dizimista?.observacoes ?? '');

    // Inicializar formatters
    cpfFormatter = MaskTextInputFormatter(
        mask: '###.###.###-##',
        filter: { "#": RegExp(r'[0-9]') }
    );
    telefoneFormatter = MaskTextInputFormatter(
        mask: '(##) #####-####',
        filter: { "#": RegExp(r'[0-9]') }
    );
    cepFormatter = MaskTextInputFormatter(
        mask: '#####-###',
        filter: { "#": RegExp(r'[0-9]') }
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
    final isDark = theme.brightness == Brightness.dark;

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

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      actionsPadding: const EdgeInsets.all(24),

      title: Text(
        widget.title,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),

      content: SizedBox(
        width: 600, // Largura aumentada para acomodar todos os campos
        child: SingleChildScrollView(
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
              const SizedBox(height: 12),
              // Dados Pessoais
              Text(
                'Dados Pessoais',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              // Nome Completo (obrigatório)
              TextField(
                controller: nomeController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Nome Completo *',
                  hintText: 'Ex: João da Silva',
                ),
              ),
              const SizedBox(height: 12),
              // CPF (obrigatório)
              TextField(
                controller: cpfController,
                inputFormatters: [cpfFormatter],
                decoration: inputDecoration.copyWith(
                  labelText: 'CPF *',
                  hintText: '000.000.000-00',
                ),
              ),
              const SizedBox(height: 12),
              // Data de Nascimento (opcional)
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dataNascimento ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      dataNascimento = date;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: dataNascimento != null ? '${dataNascimento!.day}/${dataNascimento!.month}/${dataNascimento!.year}' : ''),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Data de Nascimento',
                      hintText: 'Selecione a data',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Sexo (opcional)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Text('Sexo', style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    const Spacer(),
                    DropdownButton<String>(
                      value: sexo,
                      underline: Container(),
                      hint: Text('Selecione', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      items: [
                        DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                        DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          sexo = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dados de Contato
              Text(
                'Dados de Contato',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              // Telefone / WhatsApp (obrigatório)
              TextField(
                controller: telefoneController,
                inputFormatters: [telefoneFormatter],
                decoration: inputDecoration.copyWith(
                  labelText: 'Telefone / WhatsApp *',
                  hintText: '(00) 00000-0000',
                ),
              ),
              const SizedBox(height: 12),
              // E-mail (opcional)
              TextField(
                controller: emailController,
                decoration: inputDecoration.copyWith(
                  labelText: 'E-mail',
                  hintText: 'exemplo@email.com',
                ),
              ),
              const SizedBox(height: 16),

              // Endereço
              Text(
                'Endereço',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              // Rua
              TextField(
                controller: ruaController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Rua',
                  hintText: 'Nome da rua',
                ),
              ),
              const SizedBox(height: 12),
              // Número e Bairro em linha
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: numeroController,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Número',
                        hintText: 'Ex: 123',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: bairroController,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Bairro *',
                        hintText: 'Ex: Centro',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Cidade, Estado e CEP em linha
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: cidadeController,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Cidade *',
                        hintText: 'Ex: Iporá',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: estadoController,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Estado *',
                        hintText: 'Ex: GO',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cepController,
                      inputFormatters: [cepFormatter],
                      decoration: inputDecoration.copyWith(
                        labelText: 'CEP',
                        hintText: '00000-000',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Estado Civil
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Text('Estado Civil', style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    const Spacer(),
                    DropdownButton<String>(
                      value: estadoCivil,
                      underline: Container(),
                      hint: Text('Selecione', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      items: [
                        DropdownMenuItem(value: 'Solteiro', child: Text('Solteiro')),
                        DropdownMenuItem(value: 'Casado', child: Text('Casado')),
                        DropdownMenuItem(value: 'Viúvo', child: Text('Viúvo')),
                        DropdownMenuItem(value: 'Separado', child: Text('Separado')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          estadoCivil = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Se for casado, mostrar campos adicionais
              if (estadoCivil == 'Casado') ...[
                const SizedBox(height: 12),
                Text(
                  'Dados do Cônjuge',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nomeConjugueController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Nome do Cônjuge',
                    hintText: 'Ex: Maria da Silva',
                  ),
                ),
                const SizedBox(height: 12),
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
                      controller: TextEditingController(text: dataCasamento != null ? '${dataCasamento!.day}/${dataCasamento!.month}/${dataCasamento!.year}' : ''),
                      decoration: inputDecoration.copyWith(
                        labelText: 'Data de Casamento',
                        hintText: 'Selecione a data',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                      controller: TextEditingController(text: dataNascimentoConjugue != null ? '${dataNascimentoConjugue!.day}/${dataNascimentoConjugue!.month}/${dataNascimentoConjugue!.year}' : ''),
                      decoration: inputDecoration.copyWith(
                        labelText: 'Data de Nascimento do Cônjuge',
                        hintText: 'Selecione a data',
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Observações
              Text(
                'Observações',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: observacoesController,
                maxLines: 3,
                decoration: inputDecoration.copyWith(
                  labelText: 'Observações',
                  hintText: 'Informações adicionais...',
                ),
              ),
              const SizedBox(height: 16),

              // Consentimento (LGPD)
              Row(
                children: [
                  Checkbox(
                    value: consentimento,
                    onChanged: (value) {
                      setState(() {
                        consentimento = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Autorizo o uso dos meus dados para fins pastorais e administrativos da paróquia',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Status',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                    letterSpacing: 0.5
                ),
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
                    items: ['Ativo', 'Afastado', 'Inativo']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
            // Validação dos campos obrigatórios
            if (nomeController.text.isEmpty ||
                cpfController.text.isEmpty ||
                telefoneController.text.isEmpty ||
                bairroController.text.isEmpty ||
                cidadeController.text.isEmpty ||
                estadoController.text.isEmpty) {
              // Feedback visual de erro (Snackbar)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Preencha os campos obrigatórios: Nome, CPF, Telefone, Bairro, Cidade e Estado'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(20),
                ),
              );
              return;
            }

            // Remove as máscaras antes de salvar
            final cpfSemMascara = cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
            final telefoneSemMascara = telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');
            final cepSemMascara = cepController.text.replaceAll(RegExp(r'[^\d]'), '');

            final novoDizimista = Dizimista(
              id: widget.dizimista?.id ?? DateTime.now().millisecondsSinceEpoch,
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

            if (widget.onSave != null) {
              widget.onSave!(novoDizimista);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            widget.dizimista != null ? 'Salvar Alterações' : 'Salvar Fiel',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}