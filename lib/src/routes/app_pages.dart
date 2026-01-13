import 'package:get/get.dart';
import '../data/services/auth_middleware.dart';

import '../ui/auth/login/login_view.dart';
import '../ui/auth/password_reset/password_reset_binding.dart';
import '../ui/access_management/bindings/access_management_binding.dart';
import '../ui/access_management/views/access_management_view.dart';
import '../ui/splash/splash_view.dart';

import '../ui/contribuicoes/bindings/contribuicao_binding.dart';
import '../ui/contribuicoes/views/contribuicao_view.dart';
import '../ui/contribuicoes/views/nova_contribuicao_view.dart';
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
import '../ui/dizimistas/views/cadastro/cadastro_dizimista_view.dart';
import '../ui/dizimistas/views/dizimista_history_view.dart';
import '../ui/access_management/views/access_form_view.dart';
import '../ui/auth/password_reset/password_reset_view.dart';
import '../ui/notifications/bindings/notification_binding.dart';
import '../ui/notifications/views/notification_view.dart';
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
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dizimista,
      page: () => const DizimistaView(),
      binding: DizimistaBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dizimista_cadastro,
      page: () => CadastroDizimistaView(dizimista: Get.arguments),
      binding: DizimistaBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dizimista_editar,
      page: () => CadastroDizimistaView(dizimista: Get.arguments),
      binding: DizimistaBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dizimista_historico,
      page: () => const DizimistaHistoryView(),
      binding: DizimistaBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.access_management_form,
      page: () => AccessFormView(acesso: Get.arguments),
      binding: AccessManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.contribuicao,
      page: () => const ContribuicaoView(),
      binding: ContribuicaoBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.contribuicao_nova,
      page: () => const NovaContribuicaoView(),
      binding: ContribuicaoBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.access_management,
      page: () => const AccessManagementView(),
      binding: AccessManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: AppRoutes.help, page: () => HelpView(), binding: null),
    GetPage(name: AppRoutes.about, page: () => AboutView(), binding: null),
    GetPage(name: AppRoutes.login, page: () => LoginView(), binding: null),
    GetPage(
      name: AppRoutes.theme_settings,
      page: () => ThemeSettingsView(),
      binding: null,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.CONTACT,
      page: () => const ContactWebView(),
      binding: null,
    ),
    GetPage(
      name: AppRoutes.PARISH,
      page: () => const ParishView(),
      binding: null,
    ),
    GetPage(
      name: AppRoutes.EVENTS,
      page: () => const EventsView(),
      binding: null,
    ),
    GetPage(
      name: AppRoutes.TITHE,
      page: () => const TitheView(),
      binding: null,
    ),
    GetPage(
      name: AppRoutes.password_reset,
      page: () => const PasswordResetView(),
      binding: PasswordResetBinding(),
      // Removido middleware aqui para permitir que o usuário mude a senha se houver pendência logo após o login
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
  ];
}
