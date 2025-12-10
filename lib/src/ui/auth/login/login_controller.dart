import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/login_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final emailError = RxnString();
  final passwordError = RxnString();

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
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final success = await _authService.login(
          emailController.text.trim(),
          passwordController.text,
        );

        if (success) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.snackbar('Erro', 'Credenciais inválidas');
        }
      } catch (e) {
        Get.snackbar('Erro', 'Ocorreu um erro durante o login');
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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
