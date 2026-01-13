import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plataforma_pnsa/src/data/services/session_service.dart';
import 'package:plataforma_pnsa/src/ui/access_management/views/access_management_view.dart';
import 'package:plataforma_pnsa/src/ui/contribuicoes/views/contribuicao_view.dart';
import 'package:plataforma_pnsa/src/ui/dizimistas/views/dizimista_view.dart';
import 'package:plataforma_pnsa/src/data/services/auth_service.dart';

import '../../dashboard/views/dashboard_view.dart';
import '../../relatorios/views/report_view.dart';
import '../../profile/profile_view.dart';
import '../../support/help_view.dart';
import '../controlles/home_controller.dart';
import '../../notifications/views/notification_view.dart';
import '../../notifications/controllers/notification_controller.dart';

class NavigationItem {
  final Widget icon;
  final Widget selectedIcon;
  final String label;
  final Widget page;
  final bool isVisible;
  final bool inMenu;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
    required this.isVisible,
    this.inMenu = true,
  });
}

class HomeView extends StatelessWidget {
  final controller = Get.put(HomeController());
  final session = Get.find<SessionService>();
  final notificationController = Get.put(NotificationController());

  HomeView({Key? key}) : super(key: key);

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 840;
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 840;

  List<NavigationItem> _getNavItems() {
    final items = [
      NavigationItem(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: 'Painel',
        page: DashboardView(),
        isVisible: session.isSecretaria || session.isFinanceiro,
      ),
      NavigationItem(
        icon: const Icon(Icons.church_outlined),
        selectedIcon: const Icon(Icons.church),
        label: 'Dizimistas',
        page: DizimistaView(),
        isVisible: session.isAdmin ||
            session.isSecretaria ||
            session.isAgente ||
            session.isFinanceiro,
      ),
      NavigationItem(
        icon: const Icon(Icons.payments_outlined),
        selectedIcon: const Icon(Icons.payments),
        label: 'Contribuições',
        page: const ContribuicaoView(),
        isVisible: session.isAdmin ||
            session.isSecretaria ||
            session.isAgente ||
            session.isFinanceiro,
      ),
      NavigationItem(
        icon: const Icon(Icons.group_work_outlined),
        selectedIcon: const Icon(Icons.group_work),
        label: 'Acesso',
        page: const AccessManagementView(),
        isVisible: session.isAdmin,
      ),
      NavigationItem(
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart),
        label: 'Relatórios',
        page: ReportView(),
        isVisible:
            session.isAdmin || session.isFinanceiro || session.isSecretaria,
      ),
      NavigationItem(
        icon: Obx(() => Badge(
              label: Text(notificationController.notificationCount.toString()),
              isLabelVisible: notificationController.notificationCount > 0,
              child: const Icon(Icons.notifications_outlined),
            )),
        selectedIcon: Obx(() => Badge(
              label: Text(notificationController.notificationCount.toString()),
              isLabelVisible: notificationController.notificationCount > 0,
              child: const Icon(Icons.notifications),
            )),
        label: 'Notificações',
        page: const NotificationView(),
        isVisible: true,
      ),
      NavigationItem(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: 'Minha Conta',
        page: ProfileView(),
        isVisible: true,
        inMenu: false, // Por padrão fora do menu para ficar no footer
      ),
      NavigationItem(
        icon: const Icon(Icons.help_outline_rounded),
        selectedIcon: const Icon(Icons.help_rounded),
        label: 'Ajuda',
        page: HelpView(),
        isVisible: true,
        inMenu: true,
      ),
    ];

    final filtered = items.where((item) => item.isVisible).toList();

    // Garante que o menuItemsCount seja >= 2 para não quebrar o NavigationRail
    int menuItemsCount = filtered.where((item) => item.inMenu).length;

    if (menuItemsCount < 2) {
      // Se tiver apenas 1 item no menu, forçamos o "Minha Conta" para dentro do menu
      final profileIndex =
          filtered.indexWhere((item) => item.label == 'Minha Conta');
      if (profileIndex != -1) {
        final profile = filtered[profileIndex];
        filtered[profileIndex] = NavigationItem(
          icon: profile.icon,
          selectedIcon: profile.selectedIcon,
          label: profile.label,
          page: profile.page,
          isVisible: profile.isVisible,
          inMenu: true,
        );
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = Get.find<AuthService>();
      // Detecta se estamos carregando permissões (usuário logado mas sem dados do Firestore ainda)
      final bool isLoadingPermissions =
          auth.userData.value == null && auth.currentUser != null;

      final navItems = _getNavItems();
      final menuItems = navItems.where((item) => item.inMenu).toList();
      final bool mobile = isMobile(context);
      final bool tablet = isTablet(context);
      final bool desktop = isDesktop(context);

      // Garante que o índice não estoure se a lista de itens mudar
      if (controller.selectedIndex.value >= navItems.length) {
        controller.selectedIndex.value = 0;
      }

      // Mapeamento do índice real para o índice do menu (para destaque visual)
      int? getMenuIndex() {
        final currentItem = navItems[controller.selectedIndex.value];
        if (!currentItem.inMenu) return null;
        return menuItems.indexOf(currentItem);
      }

      Widget buildPageContent() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: navItems.map((item) => item.page).toList(),
        );
      }

      if (desktop || tablet) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: getMenuIndex(),
                onDestinationSelected: (index) {
                  final realIndex = navItems.indexOf(menuItems[index]);
                  controller.changeIndex(realIndex);
                },
                extended: desktop,
                minExtendedWidth: 240,
                groupAlignment: -1.0,
                labelType: desktop
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.church,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                            ),
                            const SizedBox(width: 12),
                            Text("PNSA",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Icon(Icons.church_outlined,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    if (isLoadingPermissions)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: desktop ? 32 : 16, vertical: 8),
                        child: const LinearProgressIndicator(
                          minHeight: 2,
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                  ],
                ),
                destinations: menuItems
                    .map((item) => NavigationRailDestination(
                          icon: item.icon,
                          selectedIcon: item.selectedIcon,
                          label: Text(item.label),
                        ))
                    .toList(),
                trailing: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildUserFooter(context, desktop, navItems,
                          isLoading: isLoadingPermissions),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                minWidth: 72,
                useIndicator: true,
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(desktop ? 24 : 0),
                  child: buildPageContent(),
                ),
              ),
            ],
          ),
        );
      }

      return Scaffold(
        key: controller.scaffoldKey,
        resizeToAvoidBottomInset: true,
        drawer: NavigationDrawer(
          selectedIndex: getMenuIndex(),
          onDestinationSelected: (int index) {
            final realIndex = navItems.indexOf(menuItems[index]);
            controller.changeIndex(realIndex);
            Navigator.pop(context);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: _buildUserFooter(context, true, navItems,
                  isLoading: isLoadingPermissions),
            ),
            if (isLoadingPermissions)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            const Divider(indent: 16, endIndent: 16),
            const SizedBox(height: 8),
            ...menuItems
                .map((item) => NavigationDrawerDestination(
                      icon: item.icon,
                      selectedIcon: item.selectedIcon,
                      label: Text(item.label),
                    ))
                .toList(),
          ],
        ),
        body: buildPageContent(),
      );
    });
  }

  Widget _buildUserFooter(
      BuildContext context, bool isExtended, List<NavigationItem> allItems,
      {bool isLoading = false}) {
    final theme = Theme.of(context);
    final isSelected =
        allItems[controller.selectedIndex.value].label == 'Minha Conta';

    return InkWell(
      onTap: () {
        final profileIndex =
            allItems.indexWhere((item) => item.label == 'Minha Conta');
        if (profileIndex != -1) {
          controller.changeIndex(profileIndex);
          // Usa a chave global em vez de Scaffold.of(context)
          if (controller.scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.pop(context);
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: isExtended ? 220 : 50,
        padding:
            EdgeInsets.symmetric(horizontal: isExtended ? 16 : 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withOpacity(0.8),
              child: Text(
                session.userName.isNotEmpty
                    ? session.userName.substring(0, 1).toUpperCase()
                    : 'U',
                style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            if (isExtended) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.userName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isLoading ? 'Sincronizando...' : session.userRole,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: isLoading
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
