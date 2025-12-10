import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plataforma_pnsa/src/routes/app_pages.dart';
import 'package:plataforma_pnsa/src/routes/app_routes.dart';
import 'package:plataforma_pnsa/src/ui/core/theme/app_theme.dart';



class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seu App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
