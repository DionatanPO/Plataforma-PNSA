import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../routes/app_routes.dart';
import 'session_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // 1. Verificação Primária: Autenticação
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // 2. Verificação de Permissões (Role-Based Access Control)
    final session = Get.find<SessionService>();

    // Se os dados do usuário ainda não carregaram, permitimos a navegação
    // e deixamos o Obx da HomeView ou o AuthGuard lidar com o redirecionamento posterior.
    if (session.userRole.isEmpty) {
      return null;
    }

    // Proteção de rotas administrativas
    if (route == AppRoutes.access_management ||
        route == AppRoutes.access_management_form) {
      if (!session.isAdmin) {
        return const RouteSettings(name: AppRoutes.home);
      }
    }

    // Proteção de rotas financeiras/dashboard
    if (route == AppRoutes.DASHBOARD) {
      if (!session.isAdmin && !session.isFinanceiro) {
        return const RouteSettings(name: AppRoutes.home);
      }
    }

    return null;
  }
}
