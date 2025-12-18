import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'password_reset_controller.dart';

class PasswordResetView extends GetView<PasswordResetController> {
  const PasswordResetView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cores profissionais (pode substituir por AppTheme.primaryColor se tiver)
    final Color primaryColor = const Color(0xFF1E3A8A);
    final Color backgroundColor = const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.grey[800]), // Caso precise voltar
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450), // Limite para Web
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone de Destaque
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Títulos
                  Text(
                    'Criar Nova Senha',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Por segurança, substitua sua senha temporária por uma nova senha permanente.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Mensagem de sucesso
                  Obx(() {
                    if (controller.successMessage.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.green[700], size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.successMessage.value!,
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Campos de Texto
                  Column(
                    children: [
                      _buildPasswordField(
                        controller: controller.newPasswordController,
                        label: 'Nova senha',
                        isObscure: controller.obscureNewPassword.value,
                        onToggle: controller.toggleNewPasswordVisibility,
                        primaryColor: primaryColor,
                        passwordResetController: controller,
                        onFieldSubmitted: (_) {
                          controller.validatePasswords();
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: controller.confirmPasswordController,
                        label: 'Confirmar senha',
                        isObscure: controller.obscureConfirmPassword.value,
                        onToggle: controller.toggleConfirmPasswordVisibility,
                        primaryColor: primaryColor,
                        passwordResetController: controller,
                        onFieldSubmitted: (_) {
                          controller.validatePasswords();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botão de Ação
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor:
                                primaryColor.withOpacity(0.6),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'DEFINIR NOVA SENHA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      )),

                  // Mensagem de erro
                  Obx(() => controller.errorMessage.value != null
                      ? Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red[700], size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para deixar o código principal mais limpo
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
    required Color primaryColor,
    required PasswordResetController passwordResetController,
    Function(String)? onFieldSubmitted,
  }) {
    return Obx(() {
      String? errorText;
      if (label == 'Nova senha') {
        errorText = passwordResetController.newPasswordError.value;
      } else if (label == 'Confirmar senha') {
        errorText = passwordResetController.confirmPasswordError.value;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            obscureText: isObscure,
            onFieldSubmitted: onFieldSubmitted,
            onChanged: (_) {
              // Validar campos sempre que o texto mudar
              passwordResetController.validatePasswords();
            },
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              floatingLabelStyle:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              prefixIcon:
                  Icon(Icons.lock_outline_rounded, color: Colors.grey[400]),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[500],
                ),
                onPressed: onToggle,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (errorText != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                errorText,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }
}
