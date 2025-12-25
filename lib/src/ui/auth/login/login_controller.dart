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
      email: '',
      password: '',
    );
    emailController.text = '';
    passwordController.text = '';
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
            await _authService.createUserInDatabase(
              user,
              user.email?.split('@')[0] ?? 'Usuário',
            );

            // Verificação de status e redirecionamento explícito
            // Isso resolve falhas de navegação em navegadores com persistência ativa
            final isActive = await _authService.isUserActiveWithRetry(user.uid);
            if (!isActive) {
              await _authService.logout();
              loginError.value = 'Sua conta foi desativada pelo administrador.';
              isLoading.value = false;
              return;
            }

            final userData = await _authService.getUserDataWithRetry(user.uid);

            // Define explicitamente o userData no serviço antes da navegação.
            // Isso garante que os controllers carregados na Home (Dashboard, Dizimistas, etc)
            // já encontrem o usuário logado e iniciem a busca de dados sem atraso.
            _authService.userData.value = userData;

            // Limpa os campos antes de navegar para a próxima tela
            emailController.clear();
            passwordController.clear();

            if (userData != null && userData.pendencia) {
              Get.offAllNamed(AppRoutes.password_reset);
            } else {
              Get.offAllNamed(AppRoutes.home);
            }
          } else {
            loginError.value = 'Não foi possível obter os dados do usuário.';
          }
        } else {
          loginError.value =
              'Credenciais inválidas. Verifique seu e-mail e senha.';
        }
        isLoading.value = false;
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
            loginError.value =
                'Ocorreu um erro durante o login. Tente novamente.';
        }
        isLoading.value = false;
      } catch (e) {
        loginError.value =
            'Ocorreu um erro inesperado. Tente novamente mais tarde.';
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

  Future<void> loginAsAgent() async {
    emailController.text = 'agentedizimo@gmail.com';
    passwordController.text = 'agente123456';
    loginError.value = null;
    isLoading.value = true;

    try {
      final success = await _authService.login(
        'agentedizimo@gmail.com',
        'agente123456',
      );

      if (success) {
        final user = _authService.currentUser;
        if (user != null) {
          final isActive = await _authService.isUserActiveWithRetry(user.uid);
          if (!isActive) {
            await _authService.logout();
            loginError.value = 'Sua conta foi desativada pelo administrador.';
            isLoading.value = false;
            return;
          }

          final userData = await _authService.getUserDataWithRetry(user.uid);
          _authService.userData.value = userData;

          emailController.clear();
          passwordController.clear();

          if (userData != null && userData.pendencia) {
            Get.offAllNamed(AppRoutes.password_reset);
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
        }
      } else {
        loginError.value = 'Credenciais de agente inválidas.';
      }
    } catch (e) {
      loginError.value = 'Erro ao realizar login de agente.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
