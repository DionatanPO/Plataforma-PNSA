import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plataforma_pnsa/src/ui/access_management/views/access_management_view.dart';
import 'package:plataforma_pnsa/src/ui/contribuicoes/views/contribuicao_view.dart';
import 'package:plataforma_pnsa/src/ui/dizimistas/views/dizimista_view.dart';

import '../../dashboard/views/dashboard_view.dart';
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
            const AccessManagementView(),
            ReportView(),
            ProfileView(),
          ],
        );
      }

      // -------------------------------------------------------------
      // LAYOUT DESKTOP / TABLET - COM NAVIGATION RAIL
      // -------------------------------------------------------------
      // -------------------------------------------------------------
      // LAYOUT DESKTOP / TABLET - COM NAVIGATION RAIL
      // -------------------------------------------------------------
      if (desktop || tablet) {
        return Scaffold(
          body: Row(
            children: [
              // Menu lateral (NavigationRail)
              NavigationRail(
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: controller.changeIndex,
                // Expandido no Desktop (Sidebar), Compacto no Tablet (Rail)
                extended: desktop,
                minExtendedWidth: 240,
                // Alinhamento no Topo (-1.0) em vez de Centro (0.0)
                groupAlignment: -1.0,
                // Se expandido, as labels ficam ao lado (type none). Se compactado, labels aparecem (type all) ou apenas selecionado.
                // NavigationRailLabelType.none é OBRIGATÓRIO se extended == true.
                labelType: desktop
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,

                // Header do Menu (Logo)
                leading: Column(
                  children: [
                    const SizedBox(height: 18),
                    if (desktop)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.church,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "PNSA",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Icon(
                          Icons.church_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),

                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Painel'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.church_outlined),
                    selectedIcon: Icon(Icons.church),
                    label: Text('Dizimistas'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.payments_outlined),
                    selectedIcon: Icon(Icons.payments),
                    label: Text('Contribuições'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.group_work_outlined),
                    selectedIcon: Icon(Icons.group_work),
                    label: Text('Acesso'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: Text('Relatórios'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Conta'),
                  ),
                ],
                minWidth: 72,
                useIndicator: true,
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
              ),

              // Conteúdo principal
              Expanded(
                child: Container(
                  // Mobile: Padding 0 para permitir que as views controlem suas bordas
                  // Desktop: Padding 24 para layout mais arejado
                  padding: EdgeInsets.all(desktop ? 24 : 0),
                  child: buildPageContent(),
                ),
              ),
            ],
          ),
        );
      }

      // -------------------------------------------------------------
      // LAYOUT MOBILE - COM NAVIGATION DRAWER
      // -------------------------------------------------------------
      return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: 'Abrir menu',
              );
            },
          ),
          title: Text(
            controller.selectedIndex.value == 0
                ? 'Painel Geral'
                : controller.selectedIndex.value == 1
                ? 'Dizimistas'
                : controller.selectedIndex.value == 2
                ? 'Contribuições'
                : controller.selectedIndex.value == 3
                ? 'Gestão de Acesso'
                : controller.selectedIndex.value == 4
                ? 'Relatórios'
                : 'Conta',
          ),
        ),
        drawer: NavigationDrawer(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (int index) {
            controller.changeIndex(index);
            Navigator.pop(context); // Fecha o drawer após selecionar
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paróquia NS Auxiliadora',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Sistema de Dízimo',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('Painel Geral'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.church_outlined),
              selectedIcon: Icon(Icons.church),
              label: Text('Dizimistas'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments),
              label: Text('Contribuições'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.group_work_outlined),
              selectedIcon: Icon(Icons.group_work),
              label: Text('Gestão de Acesso'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: Text('Relatórios'),
            ),
            const Divider(),
            const NavigationDrawerDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: Text('Conta'),
            ),
          ],
        ),
        body: buildPageContent(),
      );
    });
  }
}
