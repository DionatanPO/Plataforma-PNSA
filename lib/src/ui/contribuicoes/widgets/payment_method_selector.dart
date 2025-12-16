import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/contribuicao_controller.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;

  const PaymentMethodSelector({
    Key? key,
    required this.selectedMethod,
    required this.onMethodChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContribuicaoController>();
    final theme = Theme.of(context);

    return GetBuilder<ContribuicaoController>(
      init: controller,
      builder: (ctrl) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildPaymentChip('PIX', Icons.qr_code_rounded, theme, ctrl),
            _buildPaymentChip('Dinheiro', Icons.attach_money_rounded, theme, ctrl),
            _buildPaymentChip('Cartão', Icons.credit_card_rounded, theme, ctrl),
            _buildPaymentChip('Transferência', Icons.description_outlined, theme, ctrl),
          ],
        );
      },
    );
  }

  Widget _buildPaymentChip(String label, IconData icon, ThemeData theme, ContribuicaoController controller) {
    final isSelected = controller.metodo.value == label; // Usar o valor do controller
    final unselectedColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return InkWell(
      onTap: () {
        // Atualiza o estado no controller
        controller.metodo.value = label;
        // Chama o callback para atualizar o widget pai
        onMethodChanged(label);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
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