import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/contribuicao_controller.dart';
import '../widgets/contribuicao_desktop_table_view.dart';
import '../widgets/contribuicao_mobile_list_view.dart';
import '../../core/widgets/modern_header.dart';
import '../../core/widgets/modern_search_bar.dart';
import '../../../routes/app_routes.dart';

class ContribuicaoView extends StatefulWidget {
  const ContribuicaoView({Key? key}) : super(key: key);

  @override
  State<ContribuicaoView> createState() => _ContribuicaoViewState();
}

class _ContribuicaoViewState extends State<ContribuicaoView> {
  final ContribuicaoController controller = Get.find<ContribuicaoController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (controller.hasMore.value && !controller.isLoadingMore) {
        controller.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final backgroundColor =
        isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F9FA);

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;
    final horizontalPadding = isDesktop ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header
          ModernHeader(
            title: 'Contribuições',
            subtitle: 'Histórico de lançamentos e dízimos',
            icon: Icons.receipt_long_rounded,
          ),

          // Search Bar & Actions
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
                horizontalPadding, 24, horizontalPadding, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: ModernSearchBar(
                      controller: _searchController,
                      hintText: 'Buscar por fiél, tipo ou método...',
                      onChanged: (value) =>
                          controller.searchQuery.value = value,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List / Table
          Obx(() {
            final items = controller.paginatedContribuicoes;

            if (controller.isLoading && items.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (items.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma contribuição encontrada',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (isDesktop) {
              return ContribuicaoDesktopTableView(
                items: items,
                theme: theme,
                controller: controller,
                onReceiptPressed: (c) =>
                    controller.downloadOrShareReceiptPdf(c),
              );
            } else {
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: ContribuicaoMobileListView(
                  items: items,
                  theme: theme,
                  controller: controller,
                  surfaceColor: surfaceColor,
                  onReceiptPressed: (c) =>
                      controller.downloadOrShareReceiptPdf(c),
                ),
              );
            }
          }),

          // Status de Carregamento/Página
          Obx(() {
            if (!controller.hasMore.value &&
                controller.contribuicoes.isNotEmpty) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Fim da lista',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              sliver: SliverToBoxAdapter(
                child: controller.isLoadingMore
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const SizedBox.shrink(),
              ),
            );
          }),

          // Espaço para o FAB não cobrir conteúdo
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.contribuicao_nova),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Dízimo'),
        heroTag: 'fab_contribuicao',
      ),
    );
  }
}
