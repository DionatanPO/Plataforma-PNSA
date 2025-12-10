import 'package:get/get.dart';

class LoginModel {
  final String email;
  final String password;

  LoginModel({
    required this.email,
    required this.password,
  });

  // Validation methods
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'E-mail é obrigatório';
    }
    if (!GetUtils.isEmail(email)) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (password.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  LoginModel copyWith({
    String? email,
    String? password,
  }) {
    return LoginModel(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => 'LoginModel(email: $email, password: $password)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginModel &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}