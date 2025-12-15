import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:plataforma_pnsa/src/data/services/auth_guard.dart';
import 'package:plataforma_pnsa/src/data/services/theme_service.dart';
import 'package:plataforma_pnsa/src/ui/access_management/controllers/access_management_controller.dart';
import 'package:plataforma_pnsa/src/ui/auth/login/login_controller.dart';
import 'package:plataforma_pnsa/src/ui/contribuicoes/controllers/contribuicao_controller.dart';
import 'package:plataforma_pnsa/src/ui/dizimistas/controllers/dizimista_controller.dart';
import 'package:plataforma_pnsa/src/ui/auth/password_reset/password_reset_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:io' show Platform;

import 'app.dart';
import 'firebase_options.dart';
import 'src/data/services/auth_service.dart';
import 'src/data/services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Get.put<SessionService>(SessionService());
  Get.put<AuthService>(AuthService());
  Get.put<ThemeService>(ThemeService());
  Get.put(AuthGuard());

  // Instanciar os controllers após os serviços
  Get.put(LoginController());
  Get.put(DizimistaController());
  Get.put(ContribuicaoController());
  Get.put(AccessManagementController());
  Get.put(PasswordResetController());

  runApp(App());
}
