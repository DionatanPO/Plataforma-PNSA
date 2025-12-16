import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/contribuicao_controller.dart';

class StepNavigationButtons extends StatelessWidget {
  final int currentStep;
  final Function(int) goToStep;
  final Function() goToNextStep;
  final Function() submitForm;
  final bool dizimistaSelecionado;

  const StepNavigationButtons({
    Key? key,
    required this.currentStep,
    required this.goToStep,
    required this.goToNextStep,
    required this.submitForm,
    required this.dizimistaSelecionado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContribuicaoController>();
    final theme = Theme.of(context);

    return Row(
      children: [
        // Botão Voltar
        if (currentStep > 0)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              height: 56,
              child: OutlinedButton(
                onPressed: () => goToStep(currentStep - 1),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
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
          flex: currentStep == 0 ? 2 : 1,
          child: Container(
            margin: EdgeInsets.only(left: currentStep > 0 ? 8 : 0),
            height: 56,
            child: Obx(() {
              bool dizimistaSelecionadoValue = controller.dizimistaSelecionado.value != null;
              return ElevatedButton(
                onPressed: currentStep == 0
                    ? (dizimistaSelecionadoValue ? goToNextStep : null) // Only enable if dizimista selected
                    : submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentStep == 0
                      ? (dizimistaSelecionadoValue ? Colors.green : Colors.grey.shade400) // Verde se selecionado, cinza se não
                      : Colors.green, // Verde para concluir
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  currentStep == 0 ? 'Próximo' : 'Confirmar Lançamento',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}