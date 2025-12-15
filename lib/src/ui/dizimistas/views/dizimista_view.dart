import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
    final ruaController = TextEditingController();
    final numeroController = TextEditingController();
    final bairroController = TextEditingController();
    final cidadeController = TextEditingController();
    final estadoController = TextEditingController();
    final cepController = TextEditingController();
    final enderecoController = TextEditingController(); // Added missing controller
    final nomeConjugueController = TextEditingController();
    final observacoesController = TextEditingController();

    // Formatters para máscaras
    final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: { "#": RegExp(r'[0-9]') }
    );
    final telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: { "#": RegExp(r'[0-9]') }
    );
    final cepFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: { "#": RegExp(r'[0-9]') }
    );

    // Estado para os campos não-texto
    DateTime? dataNascimento;
    String? sexo;
    String? estadoCivil;
    DateTime? dataCasamento;
    DateTime? dataNascimentoConjugue;
    bool consentimento = false;
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
                width: 600, // Largura aumentada para acomodar todos os campos
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            initialDate: DateTime.now(),
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
                              initialDate: DateTime.now(),
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
                              initialDate: DateTime.now(),
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
                      id: controller.dizimistas.length + 1,
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
                            Text('${d.rua ?? ''}${d.numero != null && d.numero!.isNotEmpty ? ", ${d.numero}" : ""}', style: GoogleFonts.inter(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                            _actionButton(Icons.edit_outlined, Colors.blue, () => _showEditarDialog(context, d)),
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
                                d.endereco,
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
                      onPressed: () => _showEditarDialog(context, d),
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

  void _showEditarDialog(BuildContext context, Dizimista dizimista) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Controladores de texto com valores iniciais
    final nomeController = TextEditingController(text: dizimista.nome);
    final cpfController = TextEditingController(text: _formatarCPF(dizimista.cpf));
    final telefoneController = TextEditingController(text: _formatarTelefone(dizimista.telefone));
    final emailController = TextEditingController(text: dizimista.email ?? '');
    final ruaController = TextEditingController(text: dizimista.rua ?? '');
    final numeroController = TextEditingController(text: dizimista.numero ?? '');
    final bairroController = TextEditingController(text: dizimista.bairro ?? '');
    final cidadeController = TextEditingController(text: dizimista.cidade);
    final estadoController = TextEditingController(text: dizimista.estado);
    final cepController = TextEditingController(text: dizimista.cep ?? '');
    final nomeConjugueController = TextEditingController(text: dizimista.nomeConjugue ?? '');
    final observacoesController = TextEditingController(text: dizimista.observacoes ?? '');
    final enderecoController = TextEditingController(); // Added to prevent undefined error

    // Formatters para máscaras
    final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: { "#": RegExp(r'[0-9]') },
      initialText: _formatarCPF(dizimista.cpf),
    );
    final telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: { "#": RegExp(r'[0-9]') },
      initialText: _formatarTelefone(dizimista.telefone),
    );
    final cepFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: { "#": RegExp(r'[0-9]') },
      initialText: dizimista.cep ?? '',
    );

    // Outros campos
    String? sexo = dizimista.sexo;
    String? estadoCivil = dizimista.estadoCivil;
    DateTime? dataNascimento = dizimista.dataNascimento;
    DateTime? dataCasamento = dizimista.dataCasamento;
    DateTime? dataNascimentoConjugue = dizimista.dataNascimentoConjugue;
    bool consentimento = dizimista.consentimento;
    String selectedStatus = dizimista.status;

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
                'Editar Fiel',
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

                    final dizimistaAtualizado = Dizimista(
                      id: dizimista.id,
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
                      dataRegistro: dizimista.dataRegistro, // Mantém a data original
                    );

                    controller.updateDizimista(dizimistaAtualizado);
                    Navigator.of(context).pop();

                    // Feedback visual (Snackbar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fiel ${nomeController.text} atualizado com sucesso!'),
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
                    'Salvar Alterações',
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

  // Função auxiliar para formatar CPF com máscara
  String _formatarCPF(String cpf) {
    // Remove caracteres não numéricos
    String cpfNumerico = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (cpfNumerico.length != 11) return cpf; // Retorna o valor original se não tiver 11 dígitos
    return "${cpfNumerico.substring(0, 3)}.${cpfNumerico.substring(3, 6)}.${cpfNumerico.substring(6, 9)}-${cpfNumerico.substring(9, 11)}";
  }

  // Função auxiliar para formatar telefone com máscara
  String _formatarTelefone(String telefone) {
    // Remove caracteres não numéricos
    String telefoneNumerico = telefone.replaceAll(RegExp(r'[^\d]'), '');

    if (telefoneNumerico.length < 10) return telefone; // Retorna o valor original se não tiver dígitos suficientes

    if (telefoneNumerico.length == 10) { // Telefone fixo (8 dígitos + 2 dígitos DDD)
      return "(${telefoneNumerico.substring(0, 2)}) ${telefoneNumerico.substring(2, 6)}-${telefoneNumerico.substring(6, 10)}";
    } else { // Celular (9 dígitos + 2 dígitos DDD)
      return "(${telefoneNumerico.substring(0, 2)}) ${telefoneNumerico.substring(2, 7)}-${telefoneNumerico.substring(7, 11)}";
    }
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