import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:plataforma_pnsa/src/services/auth_service.dart';
import 'package:plataforma_pnsa/src/ui/auth/login/login_controller.dart';

import 'app.dart';

Future<void> main() async {
  // Garanta que o Flutter tenha sido inicializado antes de chamar qualquer coisa que interaja com o sistema
  WidgetsFlutterBinding.ensureInitialized();

  // Impede a rotação da tela
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Register services
  Get.put<AuthService>(AuthServiceImpl());
  Get.put(LoginController());

  runApp(App());
}
