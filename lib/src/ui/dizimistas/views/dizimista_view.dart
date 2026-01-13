import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';
import '../controllers/dizimista_controller.dart';
import '../models/dizimista_model.dart';
import '../widgets/dizimista_empty_state_view.dart';
import '../widgets/dizimista_mobile_list_view.dart';
import '../widgets/dizimista_desktop_table_view.dart';
import '../widgets/dizimista_search_bar_view.dart';
import '../../core/widgets/modern_header.dart';

class DizimistaView extends StatefulWidget {
  const DizimistaView({Key? key}) : super(key: key);

  @override
  State<DizimistaView> createState() => _DizimistaViewState();
}

class _DizimistaViewState extends State<DizimistaView> {
  final DizimistaController controller = Get.find<DizimistaController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onViewReady();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (controller.hasMore.value && !controller.isLoading) {
        controller.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final backgroundColor =
        isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA);
    final accentColor = theme.colorScheme.primary;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final double horizontalPadding = isDesktop ? 24.0 : 12.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: false,
        body: Obx(() {
          final items = controller.paginatedDizimistas;
          final isLoading = controller.isLoading && items.isEmpty;
          final isEmpty = !isLoading && items.isEmpty;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              ModernHeader(
                title: 'Fiéis',
                subtitle: 'Gerenciamento de cadastros',
                icon: Icons.people_rounded,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isDesktop ? 24 : 16,
                    horizontalPadding,
                    isDesktop ? 24 : 16,
                  ),
                  child: DizimistaSearchBarView(
                    controller: _searchController,
                    onChanged: (val) {
                      controller.searchQuery.value = val;
                    },
                  ),
                ),
              ),
              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: DizimistaEmptyStateView(
                    searchQuery: controller.searchQuery.value,
                  ),
                )
              else if (isDesktop)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: DizimistaDesktopTableView(
                      lista: items,
                      theme: theme,
                      surfaceColor: surfaceColor,
                      controller: controller,
                      onEditPressed: (d) =>
                          Get.toNamed(AppRoutes.dizimista_editar, arguments: d),
                      onViewHistoryPressed: (d) => _openHistoryDialog(d),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: DizimistaMobileListView(
                    lista: items,
                    theme: theme,
                    surfaceColor: surfaceColor,
                    onEditPressed: (d) =>
                        Get.toNamed(AppRoutes.dizimista_editar, arguments: d),
                    onViewHistoryPressed: (d) => _openHistoryDialog(d),
                  ),
                ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (controller.isLoadingMore.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: accentColor)),
                      )
                    else if (!controller.hasMore.value && items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Fim da lista',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'dizimista_fab_v3',
          onPressed: () => Get.toNamed(AppRoutes.dizimista_cadastro),
          icon: const Icon(Icons.add_rounded),
          label: Text('Novo Fiel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  void _openHistoryDialog(Dizimista d) {
    Get.toNamed(AppRoutes.dizimista_historico, arguments: d);
  }
}
