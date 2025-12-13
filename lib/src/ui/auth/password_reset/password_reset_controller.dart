import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class PasswordResetController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final newPasswordError = RxnString();
  final confirmPasswordError = RxnString();

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void validatePasswords() {
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    // Limpar erros anteriores
    newPasswordError.value = null;
    confirmPasswordError.value = null;

    bool hasErrors = false;

    if (newPassword.isEmpty) {
      newPasswordError.value = 'Por favor, digite sua nova senha';
      hasErrors = true;
    } else if (newPassword.length < 6) {
      newPasswordError.value = 'A senha deve ter pelo menos 6 caracteres';
      hasErrors = true;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'Por favor, confirme sua senha';
      hasErrors = true;
    } else if (newPassword != confirmPassword) {
      confirmPasswordError.value = 'As senhas não coincidem';
      hasErrors = true;
    }

    // Se não houver erros específicos de campo, limpar mensagem geral de erro
    if (!hasErrors) {
      errorMessage.value = null;
    }
  }

  Future<void> resetPassword() async {
    validatePasswords(); // Valida os campos

    // Verificar se há erros de validação
    if (newPasswordError.value != null || confirmPasswordError.value != null) {
      return; // Já temos erros de validação, não prosseguir
    }

    isLoading.value = true;
    try {
      // Atualizar a senha do usuário no Firebase Auth
      await _auth.currentUser!.updatePassword(newPasswordController.text);

      // Atualizar o status de pendência no Firestore
      await _authService.updateUserPendencyStatus(false);

      Get.snackbar('Sucesso', 'Senha redefinida com sucesso!');

      // Redirecionar para a tela principal
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      String message = 'Ocorreu um erro ao redefinir a senha.';
      if (e.code == 'weak-password') {
        message = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Por favor, faça login novamente e tente redefinir a senha.';
      }
      errorMessage.value = message;
    } catch (e) {
      errorMessage.value = 'Ocorreu um erro ao redefinir a senha: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    final AuthService _authService = Get.find<AuthService>();
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}