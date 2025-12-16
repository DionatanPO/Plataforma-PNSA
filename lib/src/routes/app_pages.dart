import 'package:get/get.dart';

import '../ui/auth/login/login_view.dart';
import '../ui/auth/password_reset/password_reset_binding.dart';
import '../ui/access_management/bindings/access_management_binding.dart';
import '../ui/access_management/views/access_management_view.dart';
import '../ui/splash/splash_view.dart';

import '../ui/contribuicoes/bindings/contribuicao_binding.dart';
import '../ui/contribuicoes/views/contribuicao_view.dart';
import '../ui/dashboard/bindings/dhasboard_binding.dart';
import '../ui/dashboard/views/dashboard_view.dart';
import '../ui/dizimistas/bindings/dizimista_binding.dart';
import '../ui/dizimistas/views/dizimista_view.dart';
import '../ui/home/bindings/home_binding.dart';
import '../ui/home/views/home_view.dart';
import '../ui/web/home/home_web_view.dart';
import '../ui/support/about_view.dart';
import '../ui/support/help_view.dart';
import '../ui/web/contact/contact_web_view.dart';
import '../ui/web/parish/parish_view.dart';
import '../ui/web/events/events_view.dart';
import '../ui/web/tithe/tithe_view.dart';
import '../ui/support/theme_settings_view.dart';
import '../ui/auth/password_reset/password_reset_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.web_home,
      page: () => HomeWebView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.dizimista,
      page: () => const DizimistaView(),
      binding: DizimistaBinding(),
    ),
    GetPage(
      name: AppRoutes.contribuicao,
      page: () => const ContribuicaoView(),
      binding: ContribuicaoBinding(),
    ),
    GetPage(
      name: AppRoutes.access_management,
      page: () => const AccessManagementView(),
      binding: AccessManagementBinding(),
    ),
    GetPage(name: AppRoutes.help, page: () => HelpView(), binding: null),
    GetPage(name: AppRoutes.about, page: () => AboutView(), binding: null),
    GetPage(name: AppRoutes.login, page: () => LoginView(), binding: null),
    GetPage(
      name: AppRoutes.theme_settings,
      page: () => ThemeSettingsView(),
      binding: null,
    ),
    GetPage(
      name: AppRoutes.CONTACT,
      page: () => const ContactWebView(),
      binding: null, // No binding for now
    ),
    GetPage(
      name: AppRoutes.PARISH,
      page: () => const ParishView(),
      binding: null, // No binding for now
    ),
    GetPage(
      name: AppRoutes.EVENTS,
      page: () => const EventsView(),
      binding: null, // No binding for now
    ),
    GetPage(
      name: AppRoutes.TITHE,
      page: () => const TitheView(),
      binding: null, // No binding for now
    ),
    GetPage(
      name: AppRoutes.password_reset,
      page: () => const PasswordResetView(),
      binding: PasswordResetBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
  ];
}
