import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plataforma_pnsa/src/ui/contribuicoes/views/contribuicao_view.dart';
import 'package:plataforma_pnsa/src/ui/dizimistas/views/dizimista_view.dart';

import '../../core/widgets/app_navigation_bar.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../functions/action_view.dart';
import '../../functions/report_view.dart';
import '../../profile/profile_view.dart';
import '../controlles/home_controller.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(HomeController());

  HomeView({Key? key}) : super(key: key);

  // -------------------------------------------------------------
  // BREAKPOINTS OFICIAIS MATERIAL 3
  // -------------------------------------------------------------
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 840;

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 840;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool mobile = isMobile(context);
      final bool tablet = isTablet(context);
      final bool desktop = isDesktop(context);

      // Conteúdo das páginas
      Widget buildPageContent() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            DashboardView(),
            DizimistaView(),
            const ContribuicaoView(),
            ReportView(),
            ProfileView(),
          ],
        );
      }

      // -------------------------------------------------------------
      // LAYOUT DESKTOP / TABLET
      // -------------------------------------------------------------
      if (desktop || tablet) {
        return Scaffold(
          body: Row(
            children: [
              // Menu lateral (AdaptiveNavigation)
              AdaptiveNavigation(
                currentIndex: controller.selectedIndex.value,
                onDestinationSelected: controller.changeIndex,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Painel Geral',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.church_outlined),
                    selectedIcon: Icon(Icons.church),
                    label: 'Dizimistas',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: 'Relatórios',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Conta',
                  ),
                ],
              ),

              // Conteúdo principal
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(desktop ? 24 : 16),
                  child: buildPageContent(),
                ),
              ),
            ],
          ),
        );
      }

      // -------------------------------------------------------------
      // LAYOUT MOBILE
      // -------------------------------------------------------------
      return Scaffold(
        body: buildPageContent(),
        bottomNavigationBar: AdaptiveNavigation(
          currentIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.changeIndex,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Painel Geral',
            ),
            NavigationDestination(
              icon: Icon(Icons.church_outlined),
              selectedIcon: Icon(Icons.church),
              label: 'Dizimistas',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Relatórios',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Conta',
            ),
          ],
        ),
      );
    });
  }
}