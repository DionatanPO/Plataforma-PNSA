import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart'; // Necessário para formatar a data visualmente
import 'dart:async';

import '../../dizimistas/controllers/dizimista_controller.dart';
import '../controllers/contribuicao_controller.dart';
import '../../dizimistas/models/dizimista_model.dart';
import '../models/contribuicao_model.dart';

class ContribuicaoView extends StatefulWidget {
  const ContribuicaoView({Key? key}) : super(key: key);

  @override
  State<ContribuicaoView> createState() => _ContribuicaoViewState();
}

class _ContribuicaoViewState extends State<ContribuicaoView> {
  final ContribuicaoController controller = Get.find<ContribuicaoController>();
  final DizimistaController dizimistaController = Get.find<DizimistaController>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _currentStep = 0; // 0 = Dizimista Selection, 1 = Contribution Form
  Timer? _debounceTimer;

  // Formatador de Moeda atualizado
  final CurrencyTextInputFormatter _currencyFormatter =
      CurrencyTextInputFormatter.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
        decimalDigits: 2,
      );

  // Variáveis de Estilo
  late ThemeData theme;
  late bool isDark;
  late Color surfaceColor;
  late Color backgroundColor;
  late Color borderColor;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _valorController.dispose();
    super.dispose();
  }

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
      // Header
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contribução',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Registro de entradas e dízimos',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      // Corpo com Scrollbar
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // Layout Responsivo: Lado a lado (Desktop) ou Empilhado (Mobile)
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(flex: 4, child: _buildStepperCard())],
                    );
                  } else {
                    return Column(children: [_buildStepperCard()]);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET: FORMULÁRIO DE NOVA ENTRADA
  // ===========================================================================
  Widget _buildStepperCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do Card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_card_rounded,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Nova Entrada',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Indicador de Etapas
          _buildStepIndicator(),

          const SizedBox(height: 32),

          // Conteúdo baseado na etapa atual
          if (_currentStep == 0)
            _buildStep1DizimistaSelection()
          else if (_currentStep == 1)
            _buildStep2ContributionForm(),

          const SizedBox(height: 24),

          // Botões de navegação entre etapas
          _buildStepNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        // Etapa 1
        Expanded(
          child: Column(
            children: [
              Container(
                height: 2,
                color: _currentStep >= 0 ? Colors.green : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _currentStep >= 0 ? Colors.green : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fiel',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _currentStep >= 0 ? Colors.green : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Etapa 2
        Expanded(
          child: Column(
            children: [
              Container(
                height: 2,
                color: _currentStep >= 1 ? Colors.green : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _currentStep >= 1 ? Colors.green : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lançamento',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _currentStep >= 1 ? Colors.green : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1DizimistaSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da etapa
        Text(
          'Selecione o Fiél',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Campo de busca
        _label('Buscar Fiéis'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome, CPF ou telefone...',
              hintStyle: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              // O FutureBuilder já lida com a atualização quando o texto muda
              // O debounce será gerenciado internamente pelo widget
              setState(() {}); // Força rebuild para atualizar o FutureBuilder
            },
          ),
        ),

        const SizedBox(height: 16),

        // Lista de resultados da busca
        if (_searchController.text.isNotEmpty) ...[
          _label('Resultados da Busca'),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Obx(() {
              final selecionado = controller.dizimistaSelecionado.value;
              return FutureBuilder<List<Dizimista>>(
                future: controller.searchDizimistasFirestore(_searchController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final List<Dizimista> dizimistasFiltrados = snapshot.data ?? [];

                  if (dizimistasFiltrados.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum fiel encontrado',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Nenhum fiel corresponde à sua pesquisa',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dizimistasFiltrados.length,
                    itemBuilder: (context, index) {
                      final dizimista = dizimistasFiltrados[index];
                      final isSelected = selecionado?.id == dizimista.id;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                dizimista.nome.isNotEmpty && dizimista.nome.split(' ').length > 1
                                    ? '${dizimista.nome.split(' ')[0][0]}${dizimista.nome.split(' ').last[0]}'.toUpperCase()
                                    : dizimista.nome.isNotEmpty ? dizimista.nome[0].toUpperCase() : '?',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            dizimista.nome,
                            style: GoogleFonts.outfit(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'CPF: ${dizimista.cpf} | Tel: ${dizimista.telefone}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                              : null,
                          onTap: () {
                            controller.dizimistaSelecionado.value = dizimista;
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ] else if (controller.dizimistaSelecionado.value != null) ...[
          // Mostrar o dizimista selecionado quando nenhum texto é digitado mas um dizimista está selecionado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Fiel Selecionado',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  controller.dizimistaSelecionado.value?.nome ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Digite para pesquisar fiéis',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Comece digitando um nome, CPF ou telefone',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Mensagem de confirmação
        if (controller.dizimistaSelecionado.value != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Fiél selecionado: ${controller.dizimistaSelecionado.value?.nome}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStep2ContributionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da etapa
        Text(
          'Dados do Lançamento',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Informações do dizimista selecionado
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fiél selecionado:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      controller.dizimistaSelecionado.value?.nome ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Tipo
        _label('Tipo'),
        _buildModernDropdown(
          value: controller.tipo,
          items: [
            'Dízimo Regular',
            'Dízimo Atrasado',
            'Oferta',
            'Doação',
          ],
          onChanged: (val) =>
              setState(() => controller.tipo = val!),
        ),

        const SizedBox(height: 20),

        // 3. SELETOR DE DATA E HORA
        _label('Data do Recebimento'),
        InkWell(
          onTap: () => _pickDateTime(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                // Observa a mudança da data no controller
                Obx(
                  () => Text(
                    '${controller.dataSelecionada.value.day.toString().padLeft(2, '0')}/${controller.dataSelecionada.value.month.toString().padLeft(2, '0')}/${controller.dataSelecionada.value.year} às ${controller.dataSelecionada.value.hour.toString().padLeft(2, '0')}:${controller.dataSelecionada.value.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // 4. Valor Monetário
        Text(
          'VALOR DA CONTRIBUIÇÃO',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _valorController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_currencyFormatter],
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'R\$ 0,00',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 5. Forma de Pagamento
        _label('Forma de Pagamento'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _paymentChip('PIX', Icons.qr_code_rounded),
            _paymentChip('Dinheiro', Icons.attach_money_rounded),
            _paymentChip('Cartão', Icons.credit_card_rounded),
            _paymentChip('Transferência', Icons.description_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildStepNavigationButtons() {
    return Row(
      children: [
        // Botão Voltar
        if (_currentStep > 0)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              height: 56,
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Voltar',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),

        // Botão Próximo/Concluir
        Expanded(
          flex: _currentStep == 0 ? 2 : 1,
          child: Container(
            margin: EdgeInsets.only(left: _currentStep > 0 ? 8 : 0),
            height: 56,
            child: Obx(() {
              bool dizimistaSelecionado = controller.dizimistaSelecionado.value != null;
              bool isStep0 = _currentStep == 0;

              if (isStep0) {
                // Para a etapa 0, o botão só é habilitado quando um dizimista é selecionado
                if (dizimistaSelecionado) {
                  // Botão habilitado (verde)
                  return ElevatedButton(
                    onPressed: _goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Próximo',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  // Botão desabilitado (cinza)
                  return ElevatedButton(
                    onPressed: null, // Desabilitado
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Próximo',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  );
                }
              } else {
                // Para a etapa 1, botão de confirmação
                return ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Confirmar Lançamento',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // WIDGET: LISTA DE HISTÓRICO
  // ===========================================================================

  // ===========================================================================
  // MÉTODOS E LÓGICA
  // ===========================================================================

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _goToNextStep() {
    if (controller.dizimistaSelecionado.value != null) {
      setState(() {
        _currentStep = 1;
      });
    } else {
      Get.snackbar(
        'Atenção',
        'Selecione um fiel antes de continuar.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(24),
        colorText: theme.colorScheme.onSurface,
      );
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    // 1. Abre o Calendário
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.dataSelecionada.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: surfaceColor,
              onSurface: theme.colorScheme.onSurface,
            ),
            dialogBackgroundColor: surfaceColor,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // 2. Abre o Relógio
    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.dataSelecionada.value),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: surfaceColor,
              dayPeriodColor: Colors.green.withOpacity(0.2),
              hourMinuteColor: backgroundColor,
              dialHandColor: Colors.green,
              dialBackgroundColor: backgroundColor,
              dialTextColor: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // 3. Combina e Salva
    final DateTime combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    controller.dataSelecionada.value = combinedDateTime;
  }

  void _submitForm() async {
    // Lógica segura para converter a string formatada em double
    String valorLimpo = _valorController.text
        .replaceAll('.', '') // Remove separador de milhar
        .replaceAll('R\$', '') // Remove simbolo
        .replaceAll(' ', '') // Remove espaços
        .replaceAll(',', '.'); // Troca vírgula por ponto

    // Atualizar o valor no controller
    controller.valor = valorLimpo;
    controller.valorNumerico = double.tryParse(valorLimpo) ?? 0.0;

    // Validar o formulário usando a lógica do controller
    if (!controller.validateForm()) {
      Get.snackbar(
        'Atenção',
        'Preencha todos os campos obrigatórios corretamente.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(24),
        colorText: theme.colorScheme.onSurface,
      );
      return;
    }

    try {
      // Criar a contribuição a partir dos dados do formulário
      final novaContribuicao = controller.createContribuicaoFromForm();

      // Salvar no Firestore
      await controller.addContribuicao(novaContribuicao);

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lançamento registrado com sucesso!', style: GoogleFonts.inter()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Limpar campos e voltar para a primeira etapa
      _valorController.clear();
      controller.dizimistaSelecionado.value = null;
      controller.dataSelecionada.value = DateTime.now();
      setState(() {
        _currentStep = 0; // Volta para a tela de seleção
      });

    } catch (e) {
      // Mostrar mensagem de erro
      Get.snackbar(
        'Erro',
        'Falha ao registrar lançamento: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(24),
        colorText: theme.colorScheme.onSurface,
        backgroundColor: Colors.red,
      );
    }
  }

  // ===========================================================================
  // COMPONENTES AUXILIARES
  // ===========================================================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          items: items.map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text(
                val,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _paymentChip(String label, IconData icon) {
    final isSelected = controller.metodo == label;
    final unselectedColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return InkWell(
      onTap: () => setState(() => controller.metodo = label),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : borderColor,
            width: isSelected ? 0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : unselectedColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
