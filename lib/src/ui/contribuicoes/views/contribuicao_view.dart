import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'dart:async';

import '../../dizimistas/controllers/dizimista_controller.dart';
import '../controllers/contribuicao_controller.dart';
import '../../dizimistas/models/dizimista_model.dart';
import '../widgets/step_indicator_widget.dart';
import '../widgets/contribution_form_widget.dart';
import '../widgets/dizimista_selection_widget.dart';
import '../widgets/step_navigation_buttons.dart';
import '../../core/widgets/modern_header.dart';

class ContribuicaoView extends StatefulWidget {
  const ContribuicaoView({Key? key}) : super(key: key);

  @override
  State<ContribuicaoView> createState() => _ContribuicaoViewState();
}

class _ContribuicaoViewState extends State<ContribuicaoView> {
  final ContribuicaoController controller = Get.find<ContribuicaoController>();
  final DizimistaController dizimistaController =
      Get.find<DizimistaController>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _currentStep = 0;
  Timer? _debounceTimer;

  final CurrencyTextInputFormatter _currencyFormatter =
      CurrencyTextInputFormatter.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
        decimalDigits: 2,
      );

  late ThemeData theme;
  late bool isDark;
  late Color surfaceColor;
  late Color backgroundColor;
  late Color borderColor;
  late Color accentColor;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    isDark = theme.brightness == Brightness.dark;
    surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    backgroundColor = isDark
        ? const Color(0xFF0D0D0D)
        : const Color(0xFFF8F9FA);
    borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    accentColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          // Modern Header
          ModernHeader(
            title: 'Contribuição',
            subtitle: 'Registro de entradas e dízimos',
            icon: Icons.payment_rounded,
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(child: _buildMainContent()),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(flex: 4, child: _buildStepperCard())],
          );
        } else {
          return _buildStepperCard();
        }
      },
    );
  }

  Widget _buildStepperCard() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header com gradiente sutil
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.05),
                  accentColor.withOpacity(0.02),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_card_rounded,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Nova Entrada',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Indicador de Etapas Melhorado
                _buildModernStepIndicator(),

                const SizedBox(height: 32),

                // Conteúdo baseado na etapa atual
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentStep == 0
                      ? _buildStep1DizimistaSelection()
                      : _buildStep2ContributionForm(),
                ),

                const SizedBox(height: 24),

                // Botões de navegação
                _buildStepNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildStepButton(0, 'Selecionar Fiel', Icons.person_search_rounded),
          const SizedBox(width: 8),
          _buildStepButton(1, 'Dados', Icons.edit_note_rounded),
        ],
      ),
    );
  }

  Widget _buildStepButton(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : icon,
              size: 18,
              color: isActive
                  ? Colors.white
                  : isCompleted
                  ? Colors.green
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1DizimistaSelection() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de busca moderno
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome, CPF ou telefone...',
              hintStyle: GoogleFonts.inter(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  size: 22,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),

        const SizedBox(height: 20),

        // Lista de resultados
        _buildSearchResults(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      if (controller.dizimistaSelecionado.value != null) {
        return _buildSelectedDizimistaCard();
      }
      return _buildEmptySearchState();
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Obx(() {
        final selecionado = controller.dizimistaSelecionado.value;
        return FutureBuilder<List<Dizimista>>(
          future: controller.searchDizimistasFirestore(_searchController.text),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                ),
              );
            }

            final List<Dizimista> dizimistasFiltrados = snapshot.data ?? [];

            if (dizimistasFiltrados.isEmpty) {
              return _buildNoResultsState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: dizimistasFiltrados.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final dizimista = dizimistasFiltrados[index];
                final isSelected = selecionado?.id == dizimista.id;

                return _buildDizimistaCard(dizimista, isSelected);
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildDizimistaCard(Dizimista dizimista, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.dizimistaSelecionado.value = dizimista;
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.08) : surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [accentColor, accentColor.withOpacity(0.8)]
                        : [
                            theme.colorScheme.onSurface.withOpacity(0.1),
                            theme.colorScheme.onSurface.withOpacity(0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    dizimista.nome.isNotEmpty &&
                            dizimista.nome.split(' ').length > 1
                        ? '${dizimista.nome.split(' ')[0][0]}${dizimista.nome.split(' ').last[0]}'
                              .toUpperCase()
                        : dizimista.nome.isNotEmpty
                        ? dizimista.nome[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dizimista.nome,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CPF: ${dizimista.cpf} • Tel: ${dizimista.telefone}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Checkmark
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDizimistaCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: Colors.green,
            ),
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
          const SizedBox(height: 8),
          Text(
            controller.dizimistaSelecionado.value?.nome ?? '',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_rounded,
            size: 56,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Digite para pesquisar',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece digitando um nome, CPF ou telefone',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
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
          const SizedBox(height: 8),
          Text(
            'Tente buscar com outros termos',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2ContributionForm() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card do dizimista selecionado
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withOpacity(0.08),
                accentColor.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person_rounded, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fiel selecionado',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.dizimistaSelecionado.value?.nome ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
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

        // Tipo
        _label('Tipo de Contribuição'),
        _buildModernDropdown(
          value: controller.tipo.value,
          items: ['Dízimo Regular', 'Dízimo Atrasado', 'Oferta', 'Doação'],
          onChanged: (val) => setState(() => controller.tipo.value = val!),
        ),

        const SizedBox(height: 20),

        // Data e Hora
        _label('Data do Recebimento'),
        InkWell(
          onTap: () => _pickDateTime(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => Text(
                      '${controller.dataSelecionada.value.day.toString().padLeft(2, '0')}/${controller.dataSelecionada.value.month.toString().padLeft(2, '0')}/${controller.dataSelecionada.value.year} às ${controller.dataSelecionada.value.hour.toString().padLeft(2, '0')}:${controller.dataSelecionada.value.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Valor
        _label('Valor da Contribuição'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withOpacity(0.05),
                accentColor.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
          ),
          child: TextField(
            controller: _valorController,
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              height: 1.2,
            ),
            onChanged: (value) => controller.valor.value = value,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'R\$ 0,00',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.15),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Forma de Pagamento
        _label('Forma de Pagamento'),
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _paymentChip('PIX', Icons.qr_code_2_rounded),
              _paymentChip('Dinheiro', Icons.payments_rounded),
              _paymentChip('Cartão', Icons.credit_card_rounded),
              _paymentChip('Transferência', Icons.sync_alt_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepNavigationButtons() {
    return StepNavigationButtons(
      currentStep: _currentStep,
      goToStep: (step) {
        setState(() {
          _currentStep = step;
        });
      },
      goToNextStep: _goToNextStep,
      submitForm: _submitForm,
      dizimistaSelecionado: controller.dizimistaSelecionado.value != null,
    );
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
        backgroundColor: surfaceColor,
        colorText: theme.colorScheme.onSurface,
        borderRadius: 12,
        icon: Icon(Icons.warning_rounded, color: Colors.orange),
      );
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.dataSelecionada.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: accentColor,
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

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.dataSelecionada.value),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: surfaceColor,
              dayPeriodColor: accentColor.withOpacity(0.2),
              hourMinuteColor: backgroundColor,
              dialHandColor: accentColor,
              dialBackgroundColor: backgroundColor,
              dialTextColor: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

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
    if (!controller.validateForm()) {
      Get.snackbar(
        'Atenção',
        'Preencha todos os campos obrigatórios corretamente.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(24),
        backgroundColor: surfaceColor,
        colorText: theme.colorScheme.onSurface,
        borderRadius: 12,
        icon: Icon(Icons.error_outline_rounded, color: Colors.orange),
      );
      return;
    }

    try {
      final novaContribuicao = controller.createContribuicaoFromForm();
      await controller.addContribuicao(novaContribuicao);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lançamento registrado com sucesso!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(24),
        ),
      );

      _valorController.clear();
      controller.valor.value = '';
      controller.dizimistaSelecionado.value = null;
      controller.dataSelecionada.value = DateTime.now();
      setState(() {
        _currentStep = 0;
      });
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao registrar lançamento: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(24),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 12,
        icon: Icon(Icons.error_rounded, color: Colors.white),
      );
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          letterSpacing: 0.3,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: surfaceColor,
          value: value,
          icon: Icon(
            Icons.expand_more_rounded,
            size: 22,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          items: items.map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text(
                val,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
    final isSelected = controller.metodo.value == label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.metodo.value = label;
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  )
                : null,
            color: isSelected ? null : backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : borderColor,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
