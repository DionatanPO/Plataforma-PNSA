import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/contribuicao_controller.dart';

class StepNavigationButtons extends StatelessWidget {
  final int currentStep;
  final bool isLastStep;
  final Function(int) goToStep;
  final Function() goToNextStep;
  final Function() submitForm;
  final bool dizimistaSelecionado;
  final bool isLoading;

  const StepNavigationButtons({
    Key? key,
    required this.currentStep,
    this.isLastStep = false,
    required this.goToStep,
    required this.goToNextStep,
    required this.submitForm,
    required this.dizimistaSelecionado,
    this.isLoading = false,
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
                onPressed: isLoading ? null : () => goToStep(currentStep - 1),
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
              bool dizimistaSelecionadoValue =
                  controller.dizimistaSelecionado.value != null;

              // Only enable Next if dizimista selected on step 0
              final bool canContinue =
                  currentStep > 0 || dizimistaSelecionadoValue;

              return ElevatedButton(
                onPressed: (canContinue && !isLoading)
                    ? (isLastStep ? submitForm : goToNextStep)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (canContinue && !isLoading)
                      ? (isLastStep ? Colors.green : theme.colorScheme.primary)
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isLastStep ? 'Confirmar Lançamento' : 'Próximo',
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
