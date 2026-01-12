import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/widgets/custom_sliver_app_bar.dart';

class SalesReportView extends StatefulWidget {
  const SalesReportView({super.key});

  @override
  State<SalesReportView> createState() => _SalesReportViewState();
}

class _SalesReportViewState extends State<SalesReportView>
    with TickerProviderStateMixin {
  // Dados de exemplo para o relatório de vendas
  final List<Map<String, dynamic>> sales = [
    {
      'date': '2026-08-27 10:15',
      'client': 'Lucas Mendes',
      'product': 'Smartphone XYZ',
      'quantity': 1,
      'unitPrice': 1200.00,
      'totalPrice': 1200.00,
      'status': 'Concluído',
      'category': 'Eletrônicos',
    },
    {
      'date': '2026-08-26 14:30',
      'client': 'Fernanda Costa',
      'product': 'Camiseta Estampada',
      'quantity': 3,
      'unitPrice': 49.90,
      'totalPrice': 149.70,
      'status': 'Concluído',
      'category': 'Roupas',
    },
    {
      'date': '2026-08-25 09:00',
      'client': 'Mariana Silva',
      'product': 'Fone de Ouvido Bluetooth',
      'quantity': 2,
      'unitPrice': 199.50,
      'totalPrice': 399.00,
      'status': 'Pendente',
      'category': 'Eletrônicos',
    },
    {
      'date': '2026-08-24 16:45',
      'client': 'Rafael Oliveira',
      'product': 'Tênis Esportivo',
      'quantity': 1,
      'unitPrice': 250.00,
      'totalPrice': 250.00,
      'status': 'Cancelado',
      'category': 'Roupas',
    },
    {
      'date': '2026-08-23 11:20',
      'client': 'Beatriz Almeida',
      'product': 'Notebook Pro',
      'quantity': 1,
      'unitPrice': 4500.00,
      'totalPrice': 4500.00,
      'status': 'Concluído',
      'category': 'Eletrônicos',
    },
  ];

  // Resumo estatístico
  Map<String, dynamic> getSummary() {
    final totalSales = sales.length;
    final totalValue = sales.fold<double>(
        0, (sum, sale) => sum + (sale['totalPrice'] as double));
    final statusCounts = {
      'Concluído': sales.where((sale) => sale['status'] == 'Concluído').length,
      'Pendente': sales.where((sale) => sale['status'] == 'Pendente').length,
      'Cancelado': sales.where((sale) => sale['status'] == 'Cancelado').length,
    };
    return {
      'totalSales': totalSales,
      'totalValue': totalValue,
      'statusCounts': statusCounts,
    };
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 800;
    final summary = getSummary();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 🔹 Cabeçalho minimalista
          CustomSliverAppBar(
            title: 'Relatório de Vendas',
            subtitle: 'Histórico e resumo de vendas recentes',
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  Get.snackbar(
                    'Filtro',
                    'Filtrar por data, status ou categoria (em desenvolvimento)',
                    backgroundColor: theme.colorScheme.primaryContainer,
                    colorText: theme.colorScheme.onPrimaryContainer,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ],
          ),

          // 🔹 Resumo estatístico
          SliverToBoxAdapter(
            child: Padding(
              padding: isWide
                  ? const EdgeInsets.symmetric(horizontal: 48, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumo',
                        style: GoogleFonts.spaceGrotesk(
                          textStyle: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total de Vendas: ${summary['totalSales']}',
                            style: GoogleFonts.spaceGrotesk(
                              textStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          Text(
                            'Valor Total: R\$ ${summary['totalValue'].toStringAsFixed(2)}',
                            style: GoogleFonts.spaceGrotesk(
                              textStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Concluídas: ${summary['statusCounts']['Concluído']}',
                        style: GoogleFonts.spaceGrotesk(
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Text(
                        'Pendentes: ${summary['statusCounts']['Pendente']}',
                        style: GoogleFonts.spaceGrotesk(
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      Text(
                        'Canceladas: ${summary['statusCounts']['Cancelado']}',
                        style: GoogleFonts.spaceGrotesk(
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Título da lista
          SliverToBoxAdapter(
            child: Padding(
              padding: isWide
                  ? const EdgeInsets.symmetric(horizontal: 48)
                  : const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Últimas Vendas',
                    style: GoogleFonts.spaceGrotesk(
                      textStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7199a6), // AppColors.primary
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detalhes das vendas realizadas',
                    style: GoogleFonts.spaceGrotesk(
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 🔹 Lista de vendas
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final sale = sales[index];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: isWide
                        ? const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 8)
                        : const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: theme.colorScheme.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Ícone de status
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: sale['status'] == 'Concluído'
                                    ? Colors.green
                                    : sale['status'] == 'Pendente'
                                        ? theme.colorScheme.secondaryContainer
                                        : theme.colorScheme.errorContainer,
                              ),
                              child: Icon(
                                sale['status'] == 'Concluído'
                                    ? Icons.check
                                    : sale['status'] == 'Pendente'
                                        ? Icons.hourglass_empty
                                        : Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 🔹 Detalhes da venda
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sale['client'],
                                    style: GoogleFonts.spaceGrotesk(
                                      textStyle:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sale['product'],
                                    style: GoogleFonts.spaceGrotesk(
                                      textStyle:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Data: ${sale['date']}',
                                    style: GoogleFonts.spaceGrotesk(
                                      textStyle:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Categoria: ${sale['category']}',
                                    style: GoogleFonts.spaceGrotesk(
                                      textStyle:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Quantidade: ${sale['quantity']} x R\$ ${sale['unitPrice'].toStringAsFixed(2)}',
                                    style: GoogleFonts.spaceGrotesk(
                                      textStyle:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 🔹 Valor e status
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${sale['totalPrice'].toStringAsFixed(2)}',
                                  style: GoogleFonts.spaceGrotesk(
                                    textStyle:
                                        theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: sale['status'] == 'Concluído'
                                          ? Colors.green
                                          : sale['status'] == 'Pendente'
                                              ? theme.colorScheme.secondary
                                              : theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sale['status'],
                                  style: GoogleFonts.spaceGrotesk(
                                    textStyle:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: sale['status'] == 'Concluído'
                                          ? Colors.green
                                          : sale['status'] == 'Pendente'
                                              ? theme.colorScheme.secondary
                                              : theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: sales.length,
            ),
          ),
        ],
      ),
    );
  }
}
