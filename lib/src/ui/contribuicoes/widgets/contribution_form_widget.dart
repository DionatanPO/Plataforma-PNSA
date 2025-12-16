import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import '../controllers/contribuicao_controller.dart';
import 'payment_method_selector.dart';

class ContributionFormWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final String onPaymentMethodChanged;
  final Function(String) onPaymentMethodChangedCallback;
  final String onTypeChanged;
  final Function(String) onTypeChangedCallback;
  final String value;
  final Function(String) onValueChanged;

  const ContributionFormWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onPaymentMethodChanged,
    required this.onPaymentMethodChangedCallback,
    required this.onTypeChanged,
    required this.onTypeChangedCallback,
    required this.value,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<ContributionFormWidget> createState() => _ContributionFormWidgetState();
}

class _ContributionFormWidgetState extends State<ContributionFormWidget> {
  late CurrencyTextInputFormatter _currencyFormatter;

  @override
  void initState() {
    super.initState();
    _currencyFormatter = CurrencyTextInputFormatter.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContribuicaoController>();
    final theme = Theme.of(context);
    final TextEditingController _valorController = TextEditingController(text: widget.value);

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
            color: theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
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
        _buildLabel('Tipo', theme),
        _buildModernDropdown(
          value: widget.onTypeChanged,
          items: const [
            'Dízimo Regular',
            'Dízimo Atrasado',
            'Oferta',
            'Doação',
          ],
          onChanged: (val) => widget.onTypeChangedCallback(val!),
          theme: theme,
        ),

        const SizedBox(height: 20),

        // 3. SELETOR DE DATA E HORA
        _buildDateSelector(context, theme, widget.selectedDate, widget.onDateChanged),

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
            color: theme.colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
          ),
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
            onChanged: (value) {
              widget.onValueChanged(value);
            },
          ),
        ),

        const SizedBox(height: 32),

        // 5. Forma de Pagamento
        _buildLabel('Forma de Pagamento', theme),
        PaymentMethodSelector(
          selectedMethod: widget.onPaymentMethodChanged,
          onMethodChanged: widget.onPaymentMethodChangedCallback,
        ),
      ],
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
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
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F6F8);
    final borderColor = theme.dividerColor.withOpacity(0.1);

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
          dropdownColor: surfaceColor,
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

  Widget _buildDateSelector(BuildContext context, ThemeData theme, DateTime selectedDate, Function(DateTime) onDateChanged) {
    return InkWell(
      onTap: () => _pickDateTime(context, selectedDate, onDateChanged),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Text(
              '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year} às ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
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
    );
  }

  Future<void> _pickDateTime(BuildContext context, DateTime initialDate, Function(DateTime) onDateChanged) async {
    // 1. Abre o Calendário
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
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
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.transparent,
              dialBackgroundColor: Colors.transparent,
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

    onDateChanged(combinedDateTime);
  }
}