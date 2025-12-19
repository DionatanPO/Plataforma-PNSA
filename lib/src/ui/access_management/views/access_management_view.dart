import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../domain/models/acesso_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/access_management_controller.dart';
import '../widgets/access_management_header.dart';
import '../widgets/access_management_search_bar.dart';
import '../widgets/access_management_desktop_list.dart';
import '../widgets/access_management_mobile_list.dart';
import '../widgets/access_management_function_cards.dart';
import '../widgets/access_management_status_cards.dart';
import '../widgets/password_reset_info_card.dart';
import '../widgets/first_access_info_card.dart';
import '../widgets/access_management_empty_state.dart';

class AccessManagementView extends StatefulWidget {
  const AccessManagementView({Key? key}) : super(key: key);

  @override
  State<AccessManagementView> createState() => _AccessManagementViewState();
}

class _AccessManagementViewState extends State<AccessManagementView> {
  final AccessManagementController controller =
      Get.find<AccessManagementController>();
  final TextEditingController _searchController = TextEditingController();

  late ThemeData theme;
  late bool isDark;
  late Color surfaceColor;
  late Color backgroundColor;
  late Color borderColor;

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    isDark = theme.brightness == Brightness.dark;
    surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8);
    borderColor = theme.dividerColor.withOpacity(0.1);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const AccessManagementHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: AccessManagementSearchBar(
                  controller: _searchController,
                  onChanged: (value) => controller.setSearchQuery(value),
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.filteredAcessos.isEmpty) {
                return SliverToBoxAdapter(
                  child: AccessManagementEmptyState(
                    searchQuery: controller.searchQuery,
                  ),
                );
              }
              return SliverLayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.crossAxisExtent > 850) {
                    return AccessManagementDesktopList(
                      acessos: controller.filteredAcessos,
                      onEditUser: _navigateToForm,
                      onResetPassword: _openResetPasswordDialog,
                      theme: theme,
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                    );
                  } else {
                    return AccessManagementMobileList(
                      acessos: controller.filteredAcessos,
                      onEditUser: _navigateToForm,
                      onResetPassword: _openResetPasswordDialog,
                      theme: theme,
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                    );
                  }
                },
              );
            }),
            _buildInfoSectionSliver(
              'Definições de Funções',
              const AccessManagementFunctionCards(),
            ),
            _buildInfoSectionSliver(
              'Legenda de Status',
              const AccessManagementStatusCards(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 24,
                  isMobile ? 24 : 40,
                  isMobile ? 16 : 24,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como Funciona o Sistema de Senhas',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool wide = constraints.maxWidth > 700;
                        return Flex(
                          direction: wide ? Axis.horizontal : Axis.vertical,
                          children: [
                            Expanded(
                                flex: wide ? 1 : 0,
                                child: const PasswordResetInfoCard()),
                            SizedBox(
                                width: wide ? 16 : 0, height: wide ? 0 : 12),
                            Expanded(
                                flex: wide ? 1 : 0,
                                child: const FirstAccessInfoCard()),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.access_management_form),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Novo Usuário',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSectionSliver(String title, Widget content) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 24,
          isMobile ? 24 : 40,
          isMobile ? 16 : 24,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  void _navigateToForm(Acesso acesso) {
    Get.toNamed(AppRoutes.access_management_form, arguments: acesso);
  }

  void _openResetPasswordDialog(Acesso acesso) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          ),
          title: Text(
            'Redefinir Senha',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Deseja redefinir a senha do usuário ${acesso.nome} para o padrão 123456? O usuário deverá trocar a senha no próximo logon.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(color: theme.colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final acessoAtualizado = Acesso(
                  id: acesso.id,
                  nome: acesso.nome,
                  email: acesso.email,
                  cpf: acesso.cpf,
                  telefone: acesso.telefone,
                  endereco: acesso.endereco,
                  funcao: acesso.funcao,
                  status: acesso.status,
                  ultimoAcesso: acesso.ultimoAcesso,
                  pendencia: true,
                );

                await controller.updateAcesso(acessoAtualizado);
                Navigator.pop(context);
                Get.snackbar('Sucesso', 'Senha redefinida com sucesso.',
                    backgroundColor: Colors.green, colorText: Colors.white);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Redefinir'),
            ),
          ],
        );
      },
    );
  }
}
