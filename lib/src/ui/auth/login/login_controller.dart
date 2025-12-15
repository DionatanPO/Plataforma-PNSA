import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../domain/models/login_model.dart';
import '../../../routes/app_routes.dart';


class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final emailError = RxnString();
  final passwordError = RxnString();
  final loginError = RxnString();

  late LoginModel _loginModel;

  LoginModel get loginModel => _loginModel;

  @override
  void onInit() {
    super.onInit();
    _loginModel = LoginModel(
      email: 'test@example.com',
      password: 'password123',
    );
    emailController.text = _loginModel.email;
    passwordController.text = _loginModel.password;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  String? validateEmail(String? email) {
    emailError.value = LoginModel.validateEmail(email);
    return emailError.value;
  }

  String? validatePassword(String? password) {
    passwordError.value = LoginModel.validatePassword(password);
    return passwordError.value;
  }

  Future<void> login() async {
    loginError.value = null;
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final success = await _authService.login(
          emailController.text.trim(),
          passwordController.text,
        );

        if (success) {
          final user = _authService.currentUser;
          if (user != null) {
                        // Salvar informações do usuário no Firestore
                        await _authService.createUserInDatabase(user, user.email?.split('@')[0] ?? 'Usuário');
            
                        // A lógica de redirecionamento foi removida daqui.
                        // O AuthGuard será responsável por redirecionar o usuário
                        // para a tela correta (home ou redefinição de senha) após
                        // a mudança de estado de autenticação ser detectada.
          } else {
            loginError.value = 'Não foi possível obter os dados do usuário.';
          }
        } else {
          loginError.value = 'Credenciais inválidas. Verifique seu e-mail e senha.';
        }
      } on FirebaseAuthException catch (e) {
        // Mapear códigos de erro do Firebase para mensagens amigáveis
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            loginError.value = 'E-mail ou senha incorretos.';
            break;
          case 'invalid-email':
            loginError.value = 'O formato do e-mail é inválido.';
            break;
          case 'user-disabled':
            loginError.value = 'Este usuário foi desativado.';
            break;
          default:
            loginError.value = 'Ocorreu um erro durante o login. Tente novamente.';
        }
      } catch (e) {
        loginError.value = 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
      } finally {
        isLoading.value = false;
      }
    }
  }

  void updateModel() {
    _loginModel = _loginModel.copyWith(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }

  void logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
