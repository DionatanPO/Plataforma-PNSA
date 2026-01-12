import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:plataforma_pnsa/src/data/services/auth_guard.dart';
import 'package:plataforma_pnsa/src/data/services/theme_service.dart';
import 'package:plataforma_pnsa/src/ui/auth/login/login_controller.dart';
import 'package:plataforma_pnsa/src/ui/auth/password_reset/password_reset_controller.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/data/services/auth_service.dart';
import 'src/data/services/session_service.dart';
import 'src/core/services/data_repository_service.dart';

import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Instanciar os serviços principais
  Get.put<SessionService>(SessionService());
  Get.put<AuthService>(AuthService());
  Get.put<DataRepositoryService>(DataRepositoryService());
  Get.put<ThemeService>(ThemeService());
  Get.put(AuthGuard());

  // Controller de Login (necessário para a tela inicial se for Login)
  Get.put(LoginController());
  Get.put(PasswordResetController());

  runApp(App());
}
