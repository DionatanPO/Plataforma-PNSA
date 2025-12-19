import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Se o usuário NÃO estiver autenticado no Firebase, redireciona para o login
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // O usuário tentou acessar uma rota protegida sem estar logado
      return const RouteSettings(name: AppRoutes.login);
    }

    // Se estiver logado, permite o acesso à rota solicitada
    return null;
  }
}
