import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../dizimistas/controllers/dizimista_controller.dart';
import '../controllers/contribuicao_controller.dart';
import '../../dizimistas/models/dizimista_model.dart';
import '../widgets/step_navigation_buttons.dart';
import '../../core/widgets/modern_header.dart';
import '../../../routes/app_routes.dart';

class NovaContribuicaoView extends StatefulWidget {
  const NovaContribuicaoView({Key? key}) : super(key: key);

  @override
  State<NovaContribuicaoView> createState() => _NovaContribuicaoViewState();
}

class _NovaContribuicaoViewState extends State<NovaContribuicaoView> {
  final ContribuicaoController controller = Get.find<ContribuicaoController>();
  final DizimistaController dizimistaController =
      Get.find<DizimistaController>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _currentStep = 0;
  Timer? _debounceTimer;
  Future<List<Dizimista>>? _searchFuture;
  int _displayYear = DateTime.now().year;
  bool _isSucceeded = false;

  @override
  void initState() {
    super.initState();
    controller.resetForm();
  }

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

  bool get isMobile => MediaQuery.of(context).size.width < 600;

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
    backgroundColor =
        isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA);
    borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    accentColor = theme.colorScheme.primary;

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          slivers: [
            // Modern Header
            ModernHeader(
              title: 'Novo Lançamento',
              subtitle: 'Registro de entradas e dízimos',
              icon: Icons.add_card_rounded,
              showBackButton: true,
            ),

            // Content
            SliverPadding(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              sliver: SliverToBoxAdapter(child: _buildMainContent()),
            ),

            // Espaço adicional para o teclado
            SliverToBoxAdapter(
              child: SizedBox(height: bottomPadding + 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menu Lateral de Etapas
              SizedBox(
                width: 250,
                child: _buildLateralStepper(),
              ),
              const SizedBox(width: 24),
              // Conteúdo Principal
              Expanded(
                child: _buildStepperCard(isLateral: true),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildStepperCard(),
            ],
          );
        }
      },
    );
  }

  Widget _buildLateralStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLateralStepItem(
              0, 'Selecionar Fiel', Icons.person_search_rounded),
          _buildDivider(),
          _buildLateralStepItem(
              1, 'Definir Período', Icons.calendar_month_rounded),
          _buildDivider(),
          _buildLateralStepItem(
              2, 'Dados do Pagamento', Icons.credit_card_rounded),
          _buildDivider(),
          _buildLateralStepItem(
              3, 'Resumo do Lançamento', Icons.verified_user_rounded),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 2,
      color: borderColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildLateralStepItem(int step, String title, IconData icon) {
    final bool isActive = _currentStep == step;
    final bool isCompleted = _currentStep > step;

    return InkWell(
      onTap: () {
        // Allow navigation only to previous steps or if current is valid
        if (step < _currentStep) setState(() => _currentStep = step);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? accentColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? accentColor
                    : (isCompleted
                        ? Colors.green
                        : theme.disabledColor.withOpacity(0.2)),
                shape: BoxShape.circle,
              ),
              child: Icon(isCompleted ? Icons.check : icon,
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? accentColor
                      : theme.colorScheme.onSurface
                          .withOpacity(isCompleted ? 0.8 : 0.5),
                  fontSize: 14,
                ),
              ),
            ),
            if (isActive)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: accentColor)
          ],
        ),
      ),
    );
  }

  Widget _buildStepperCard({bool isLateral = false}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
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
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              children: [
                if (!isLateral) _buildModernStepIndicator(),
                if (!isLateral) const SizedBox(height: 32),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _getStepContent(),
                ),
                const SizedBox(height: 24),
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
          _buildStepButton(0, 'Fiel', Icons.person_search_rounded),
          const SizedBox(width: 4),
          _buildStepButton(1, 'Período', Icons.calendar_month_rounded),
          const SizedBox(width: 4),
          _buildStepButton(2, 'Pagamento', Icons.credit_card_rounded),
          const SizedBox(width: 4),
          _buildStepButton(3, 'Resumo', Icons.verified_user_rounded),
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
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: accentColor.withOpacity(0.25)),
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
                  color: accentColor,
                  size: 22,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 14 : 18,
              ),
            ),
            onChanged: (value) {
              if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                _searchFuture = controller.searchDizimistasFirestore(value);
                setState(() {});
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              onPressed: () async {
                await Get.toNamed(AppRoutes.dizimista_cadastro);
                if (mounted && _searchController.text.isNotEmpty) {
                  _searchFuture = controller
                      .searchDizimistasFirestore(_searchController.text);
                  setState(() {});
                }
              },
              icon: const Icon(Icons.person_add_rounded,
                  size: 18, color: Colors.white),
              label: Text(
                'Cadastrar Novo Fiel',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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

    if (_searchFuture == null && _searchController.text.isNotEmpty) {
      _searchFuture =
          controller.searchDizimistasFirestore(_searchController.text);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: borderColor),
      ),
      child: FutureBuilder<List<Dizimista>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: accentColor),
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
              return Obx(() {
                final isSelected =
                    controller.dizimistaSelecionado.value?.id == dizimista.id;
                return _buildDizimistaCard(dizimista, isSelected);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildDizimistaCard(Dizimista dizimista, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.dizimistaSelecionado.value = dizimista;
          _goToNextStep();
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
                    () {
                      if (dizimista.nome.isEmpty) return '?';
                      final parts = dizimista.nome
                          .trim()
                          .split(' ')
                          .where((p) => p.isNotEmpty)
                          .toList();
                      if (parts.length > 1) {
                        return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
                      }
                      return parts[0][0].toUpperCase();
                    }(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
              if (!isSelected)
                IconButton(
                  icon: Icon(Icons.edit_rounded,
                      size: 20, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () => Get.toNamed(AppRoutes.dizimista_editar,
                      arguments: dizimista),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(32, 32)),
                  visualDensity: VisualDensity.compact,
                ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration:
                      BoxDecoration(color: accentColor, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDizimistaCard() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child:
                Icon(Icons.check_circle_rounded, size: 40, color: Colors.green),
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
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.dizimista_editar,
                arguments: controller.dizimistaSelecionado.value),
            icon: Icon(Icons.edit_rounded, size: 16),
            label: Text('Editar Dados'),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.search_rounded,
              size: 56, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('Digite para pesquisar',
              style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Comece digitando um nome, CPF ou telefone',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('Nenhum fiel encontrado',
              style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tente buscar com outros termos',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1DizimistaSelection();
      case 1:
        return _buildStep2MonthSelection();
      case 2:
        return _buildStep3PaymentData();
      case 3:
        return _buildStep4Summary();
      default:
        return Container();
    }
  }

  bool _isManualSelection = false;

  Widget _buildStep2MonthSelection() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Referência da Contribuição',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecione a quais meses este pagamento se refere.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.5,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, constraints) {
          final double cardWidth = (constraints.maxWidth > 600)
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: cardWidth,
                child: _buildQuickOptionCard(
                  title: 'Mês Atual',
                  subtitle: _formatMonthAndYear(DateTime.now()),
                  icon: Icons.calendar_today_rounded,
                  color: Colors.blue,
                  onTap: () {
                    setState(() {
                      _isManualSelection = false;
                    });
                    controller.limparCompetencias();
                    final now = DateTime.now();
                    final mesRef =
                        '${now.year}-${now.month.toString().padLeft(2, '0')}';
                    controller.adicionarCompetencia(mesRef, 0);
                    _goToNextStep();
                  },
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: _buildQuickOptionCard(
                  title: 'Seleção Manual',
                  subtitle: 'Selecione múltiplos meses',
                  icon: Icons.edit_calendar_rounded,
                  color: Colors.orange,
                  onTap: () {
                    setState(() {
                      _isManualSelection = true;
                    });
                  },
                ),
              ),
            ],
          );
        }),
        if (_isManualSelection) ...[
          const SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmbeddedMonthPicker(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3PaymentData() {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedMonthsSummary(),
        const SizedBox(height: 32),

        // VALOR E DATA AQUI
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Valor da Contribuição'),
                  Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: _valorController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_currencyFormatter],
                      onChanged: (val) => controller.valor.value = val,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'R\$ 0,00',
                        prefixIcon: Icon(Icons.attach_money_rounded,
                            color: accentColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  if (controller.competencias.length > 1) ...[
                    const SizedBox(height: 16),
                    _label('Modo de Distribuição'),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _paymentChip(
                                'Integral / Cada Mês',
                                Icons.repeat_rounded,
                                isSelectedOverride:
                                    controller.distribuicaoModo.value ==
                                        DistribuicaoModo.integral,
                                onTapOverride: () => controller.distribuicaoModo
                                    .value = DistribuicaoModo.integral,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _paymentChip(
                                'Dividir Valor Total',
                                Icons.splitscreen_rounded,
                                isSelectedOverride:
                                    controller.distribuicaoModo.value ==
                                        DistribuicaoModo.rateado,
                                onTapOverride: () => controller.distribuicaoModo
                                    .value = DistribuicaoModo.rateado,
                              ),
                            ),
                          ],
                        )),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Data do Pagamento'),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.dataSelecionada.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) => Theme(
                          data: theme.copyWith(
                            colorScheme: theme.colorScheme.copyWith(
                              primary: accentColor,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        controller.dataSelecionada.value = picked;
                        // Sincroniza todas as competências com esta data
                        for (var c in controller.competencias) {
                          controller.atualizarDataCompetencia(
                              c.mesReferencia, picked);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 20,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 12),
                          Obx(() => Text(
                                DateFormat('dd/MM/yy')
                                    .format(controller.dataSelecionada.value),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        _label('Como foi recebido?'),
        Obx(() => Wrap(spacing: 12, runSpacing: 12, children: [
              _paymentChip('PIX', Icons.qr_code_2_rounded),
              _paymentChip('Dinheiro', Icons.payments_rounded),
              _paymentChip('Cartão', Icons.credit_card_rounded),
              _paymentChip('Transferência', Icons.sync_alt_rounded)
            ])),
        const SizedBox(height: 32),
        _label('Status do Pagamento'),
        Obx(() => Row(children: [
              _statusChip('Pago', Icons.check_circle_rounded, Colors.green),
              const SizedBox(width: 16),
              _statusChip('A Receber', Icons.pending_rounded, Colors.orange),
            ])),
        const SizedBox(height: 32),
        _label('Observação (Opcional)'),
        Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor)),
          child: TextField(
            onChanged: (val) => controller.observacao.value = val,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
                hintText: 'Ex: Pagamento referente aos meses em atraso...',
                hintStyle: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16)),
          ),
        ),
        const SizedBox(height: 32),
        // Removido o summary card daqui, pois agora existe uma 4ª etapa dedicada
      ],
    );
  }

  void _addAllMonthsCurrentYear() {
    controller.limparCompetencias();
    final now = DateTime.now();
    final year = now.year;
    final Map<String, DateTime> months = {};
    for (int i = 1; i <= 12; i++) {
      final mesRef = '$year-${i.toString().padLeft(2, '0')}';
      months[mesRef] = DateTime(year, i, 10);
    }
    controller.adicionarVariasCompetencias(months);
  }

  Widget _buildQuickOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: surfaceColor,
              border: Border.all(color: color.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface)),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmbeddedMonthPicker() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left_rounded,
                    color: theme.colorScheme.onSurface),
                onPressed: () => setState(() => _displayYear--),
              ),
              Text(
                _displayYear.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface),
                onPressed: () => setState(() => _displayYear++),
              ),
            ],
          ),
        ),
        Obx(() {
          final selectedKeys =
              controller.competencias.map((c) => c.mesReferencia).toSet();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 3 : 6,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final monthKey =
                  '$_displayYear-${month.toString().padLeft(2, '0')}';
              final isSelected = selectedKeys.contains(monthKey);

              return InkWell(
                  onTap: () {
                    if (isSelected) {
                      controller.removerCompetencia(monthKey);
                    } else {
                      controller.adicionarCompetencia(monthKey, 0);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                          color: isSelected ? accentColor : surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected ? accentColor : borderColor)),
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text(
                                DateFormat('MMM', 'pt_BR')
                                    .format(DateTime(2024, month))
                                    .toUpperCase(),
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white
                                        : theme.colorScheme.onSurface)),
                          ]))));
            },
          );
        }),
      ],
    );
  }

  String _formatMonthAndYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'pt_BR').format(date);
  }

  Widget _buildSelectedDizimistaSummary() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          accentColor.withOpacity(0.08),
          accentColor.withOpacity(0.04)
        ]),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.person_rounded, color: accentColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fiel selecionado',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(controller.dizimistaSelecionado.value?.nome ?? '',
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
          IconButton(
              icon: Icon(Icons.edit_rounded, size: 20, color: accentColor),
              onPressed: () => setState(() => _currentStep = 0),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(const Size(32, 32)),
              visualDensity: VisualDensity.compact),
        ],
      ),
    );
  }

  Widget _buildSelectedMonthsSummary() {
    return Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_today_rounded,
                  size: 20, color: Colors.purple)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Meses Referentes',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Obx(() {
                  if (controller.competencias.isEmpty)
                    return Text('Nenhum mês selecionado',
                        style: GoogleFonts.inter(color: Colors.red));

                  // Sort competencies
                  final sorted = controller.competencias.toList()
                    ..sort(
                        (a, b) => a.mesReferencia.compareTo(b.mesReferencia));

                  if (sorted.length > 3) {
                    return Text(
                        '${sorted.length} meses selecionados (${_formatMesReferencia(sorted.first.mesReferencia)} a ${_formatMesReferencia(sorted.last.mesReferencia)})',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600, fontSize: 14));
                  }

                  return Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: sorted
                          .map((c) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(_formatMesReferencia(c.mesReferencia),
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.purple))))
                          .toList());
                })
              ])),
          IconButton(
              icon: Icon(Icons.edit_rounded,
                  size: 20, color: theme.colorScheme.onSurfaceVariant),
              onPressed: () => setState(() => _currentStep = 1),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(const Size(32, 32)),
              visualDensity: VisualDensity.compact),
        ]));
  }

  void _pickDateForCompetencia(String mesAno, DateTime? dataAtual) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dataAtual ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
          data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(primary: accentColor)),
          child: child!),
    );
    if (pickedDate != null) {
      controller.atualizarDataCompetencia(mesAno, pickedDate);
      setState(() {});
    }
  }

  Widget _buildCompetenciaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _label('Meses de Referência (Competência)'),
          TextButton.icon(
              onPressed: () => _showMonthPicker(),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('Adicionar Mês'),
              style: TextButton.styleFrom(foregroundColor: accentColor))
        ]),
        const SizedBox(height: 8),
        Obx(() {
          final isAtrasado = controller.tipo.value == 'Dízimo Atrasado';
          if (controller.competencias.isEmpty) {
            return InkWell(
              onTap: () => _showMonthPicker(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: isAtrasado
                        ? Colors.orange.withOpacity(0.05)
                        : backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isAtrasado
                            ? Colors.orange.withOpacity(0.3)
                            : borderColor)),
                child: Column(
                  children: [
                    Icon(
                        isAtrasado
                            ? Icons.event_busy_rounded
                            : Icons.history_edu_rounded,
                        size: 36,
                        color: isAtrasado
                            ? Colors.orange
                            : theme.colorScheme.onSurface.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Text(
                        isAtrasado
                            ? 'Outros Meses: Quais meses?'
                            : 'Nenhum mês de referência selecionado',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight:
                                isAtrasado ? FontWeight.w700 : FontWeight.w500,
                            color: isAtrasado
                                ? Colors.orange.shade800
                                : theme.colorScheme.onSurface
                                    .withOpacity(0.4))),
                    const SizedBox(height: 4),
                    Text(
                        isAtrasado
                            ? 'Toque aqui para indicar os meses que o fiel está pagando'
                            : 'Opcional: use para outros meses (atrasados ou futuros)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.3))),
                  ],
                ),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor)),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.competencias.length,
                  separatorBuilder: (context, index) => Divider(
                      height: 1, color: borderColor, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final comp = controller.competencias[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.only(left: 16, right: 8),
                      title: Text(_formatMesReferencia(comp.mesReferencia),
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: comp.dataPagamento != null
                          ? Text(
                              'Data: ${comp.dataPagamento!.day.toString().padLeft(2, '0')}/${comp.dataPagamento!.month.toString().padLeft(2, '0')}/${comp.dataPagamento!.year}',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5)))
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.calendar_today_rounded,
                                  size: 18,
                                  color: accentColor.withOpacity(0.7)),
                              onPressed: () => _pickDateForCompetencia(
                                  comp.mesReferencia, comp.dataPagamento)),
                          const SizedBox(width: 4),
                          Text(_currencyFormatter.formatDouble(comp.valor),
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor)),
                          const SizedBox(width: 4),
                          IconButton(
                              icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  size: 20,
                                  color: Colors.redAccent),
                              onPressed: () => controller
                                  .removerCompetencia(comp.mesReferencia)),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              size: 14, color: accentColor),
                          const SizedBox(width: 8),
                          Text('Valor total dividido automaticamente',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: accentColor))
                        ])),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatMesReferencia(String mesRef) {
    final parts = mesRef.split('-');
    if (parts.length != 2) return mesRef;
    final year = parts[0];
    final month = int.tryParse(parts[1]) ?? 1;
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return '${months[month - 1]} de $year';
  }

  void _showMonthPicker() async {
    final now = DateTime.now();
    int selectedYear = now.year;
    final Map<String, DateTime> selectedCompetencias = {};
    for (var c in controller.competencias) {
      selectedCompetencias[c.mesReferencia] =
          c.dataPagamento ?? controller.dataSelecionada.value;
    }
    await Get.dialog(
      StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Selecionar Meses',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
                value: selectedYear,
                underline: const SizedBox(),
                items: List.generate(5, (index) => now.year - 2 + index)
                    .map((y) => DropdownMenuItem(
                        value: y,
                        child: Text(y.toString(),
                            style: GoogleFonts.inter(fontSize: 14))))
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedYear = val!))
          ]),
          content: SizedBox(
            width: 320,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final monthKey =
                    '$selectedYear-${month.toString().padLeft(2, '0')}';
                final isSelected = selectedCompetencias.containsKey(monthKey);
                return InkWell(
                    onTap: () async {
                      if (isSelected) {
                        setDialogState(
                            () => selectedCompetencias.remove(monthKey));
                      } else {
                        // Ao clicar, já abre o seletor de data
                        final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(
                                selectedYear,
                                month,
                                (selectedYear == now.year && month == now.month)
                                    ? now.day
                                    : 1),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            helpText:
                                'DATA DO PAGAMENTO PARA ${_formatMonth(month).toUpperCase()}',
                            builder: (context, child) => Theme(
                                data: theme.copyWith(
                                    colorScheme: theme.colorScheme
                                        .copyWith(primary: accentColor)),
                                child: child!));
                        if (picked != null) {
                          setDialogState(
                              () => selectedCompetencias[monthKey] = picked);
                        }
                      }
                    },
                    onLongPress: () async {
                      // Se já estiver selecionado, permite trocar a data sem desmarcar
                      if (isSelected) {
                        final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedCompetencias[monthKey]!,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            helpText:
                                'ALTERAR DATA PARA ${_formatMonth(month).toUpperCase()}',
                            builder: (context, child) => Theme(
                                data: theme.copyWith(
                                    colorScheme: theme.colorScheme
                                        .copyWith(primary: accentColor)),
                                child: child!));
                        if (picked != null) {
                          setDialogState(
                              () => selectedCompetencias[monthKey] = picked);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? accentColor
                                : theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isSelected ? accentColor : borderColor)),
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(_formatMonth(month),
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : theme.colorScheme.onSurface)),
                                    if (isSelected)
                                      Text(
                                          DateFormat('dd/MM').format(
                                              selectedCompetencias[monthKey]!),
                                          style: GoogleFonts.inter(
                                              fontSize: 9,
                                              color: Colors.white
                                                  .withOpacity(0.8)))
                                  ]),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Icon(Icons.edit_calendar_rounded,
                                    size: 10,
                                    color: Colors.white.withOpacity(0.6)),
                              ),
                          ],
                        )));
              },
            ),
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 8),
                  child: Text(
                    'Dica: Clique no mês para selecionar e definir a data.',
                    style: GoogleFonts.inter(
                        fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () {
                          controller.adicionarVariasCompetencias(
                              selectedCompetencias);
                          Get.back();
                        },
                        child: const Text('Confirmar')),
                  ],
                ),
              ],
            )
          ],
        );
      }),
    );
  }

  String _formatMonth(int m) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return months[m - 1];
  }

  Widget _buildStepNavigationButtons() {
    return Obx(() => StepNavigationButtons(
          currentStep: _currentStep,
          isLastStep: _currentStep == 3,
          goToStep: (step) => setState(() => _currentStep = step),
          goToNextStep: _goToNextStep,
          submitForm: _submitForm,
          dizimistaSelecionado: controller.dizimistaSelecionado.value != null,
          isLoading: controller.isLoading || _isSucceeded,
        ));
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (controller.dizimistaSelecionado.value != null) {
        setState(() => _currentStep = 1);
      } else {
        _showErrorSnackbar('Selecione um fiel antes de continuar.');
      }
    } else if (_currentStep == 1) {
      if (controller.competencias.isNotEmpty) {
        setState(() => _currentStep = 2);
      } else {
        _showErrorSnackbar('Selecione ao menos um mês de referência.');
      }
    } else if (_currentStep == 2) {
      // Validar valor > 0
      String valorLimpo = controller.valor.value
          .replaceAll('.', '')
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');
      double valorDouble = double.tryParse(valorLimpo) ?? 0;

      if (valorDouble <= 0) {
        _showErrorSnackbar('O valor da contribuição deve ser maior que zero.');
        return;
      }

      if (controller.metodo.value.isNotEmpty) {
        setState(() => _currentStep = 3);
      } else {
        _showErrorSnackbar('Selecione o método de pagamento.');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar('Atenção', message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(24),
        backgroundColor: surfaceColor,
        colorText: theme.colorScheme.onSurface,
        borderRadius: 12,
        icon: const Icon(Icons.warning_rounded, color: Colors.orange));
  }

  void _submitForm() async {
    if (!controller.validateForm()) {
      Get.snackbar(
          'Atenção', 'Preencha todos os campos obrigatórios corretamente.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(24),
          backgroundColor: surfaceColor,
          colorText: theme.colorScheme.onSurface,
          borderRadius: 12,
          icon: Icon(Icons.error_outline_rounded, color: Colors.orange));
      return;
    }
    if (controller.tipo.value.contains('Dízimo') &&
        controller.competencias.isEmpty) {
      Get.snackbar('Mês de Referência',
          'Por favor, selecione ao menos um mês de referência para dízimos.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(24),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          borderRadius: 12,
          icon: Icon(Icons.calendar_month_rounded, color: Colors.white));
      return;
    }
    try {
      // Lock the form immediately to prevent double submissions
      setState(() => _isSucceeded = true);

      // Criamos as contribuições separadas para o banco de dados
      final listaParaSalvar = controller.createContribuicoesFromFormSplit();

      // Salvamos cada mês como um lançamento separado no Firestore
      await controller.addContribuicoes(listaParaSalvar);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Lançamentos registrados com sucesso!',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  Text(
                      '${listaParaSalvar.length} mês(es) foram lançados individualmente.',
                      style: GoogleFonts.inter(fontSize: 12))
                ]))
          ]),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(24)));

      // Aguarda um momento para o usuário ver o sucesso e o botão ficar travado
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        _valorController.clear();
        _searchController.clear();
        _searchFuture = null;
        _displayYear = DateTime.now().year;
        controller.resetForm();
        Get.back(); // Volta para a listagem
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSucceeded = false);
      }
      Get.snackbar('Erro', 'Falha ao registrar lançamento: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(24),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          borderRadius: 12,
          icon: Icon(Icons.error_rounded, color: Colors.white));
    }
  }

  Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.3)));

  Widget _statusChip(String label, IconData icon, Color color) {
    final isSelected = controller.status.value == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.status.value = label,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected ? color : borderColor, width: 1.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: 20, color: isSelected ? color : theme.disabledColor),
              const SizedBox(width: 10),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? color
                          : theme.colorScheme.onSurface.withOpacity(0.6))),
            ])),
      ),
    );
  }

  Widget _paymentChip(String label, IconData icon,
      {bool? isSelectedOverride, VoidCallback? onTapOverride}) {
    final isSelected = isSelectedOverride ?? controller.metodo.value == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapOverride ?? () => controller.metodo.value = label,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 18, vertical: isMobile ? 10 : 14),
            decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.8)])
                    : null,
                color: isSelected ? null : backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected ? Colors.transparent : borderColor,
                    width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : null),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 10),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withOpacity(0.7)))
            ])),
      ),
    );
  }

  Widget _buildStep4Summary() {
    return Column(
      key: const ValueKey('step4'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: Colors.green, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revisão Final',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Confira os dados antes de confirmar o lançamento.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSummaryCard(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ao confirmar, os lançamentos serão registrados e você poderá gerar o recibo na próxima tela.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      if (controller.valor.value.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2), width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.verified_user_rounded,
                color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text('Resumo do Lançamento',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary))
          ]),
          const SizedBox(height: 16),
          _summaryRow('Fiel:', controller.dizimistaSelecionado.value?.nome),
          _summaryRow('Método:', controller.metodo.value),
          _summaryRow('Status:', controller.status.value),
          if (controller.competencias.isNotEmpty) ...[
            const Divider(height: 24),
            Text('Períodos Selecionados:',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),
            ...controller.competencias.map((comp) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12,
                            color: theme.colorScheme.primary.withOpacity(0.5)),
                        const SizedBox(width: 8),
                        Text(_formatMesReferencia(comp.mesReferencia),
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          NumberFormat.simpleCurrency(locale: 'pt_BR')
                              .format(comp.valor),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Em: ${DateFormat('dd/MM').format(comp.dataPagamento ?? controller.dataSelecionada.value)}',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total do Lançamento:',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7))),
            Text(
                NumberFormat.simpleCurrency(locale: 'pt_BR')
                    .format(controller.totalContribuicao),
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: theme.colorScheme.primary))
          ]),
        ]),
      );
    });
  }

  Widget _summaryRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14)),
          Text(value,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  fontSize: 14))
        ]));
  }
}
