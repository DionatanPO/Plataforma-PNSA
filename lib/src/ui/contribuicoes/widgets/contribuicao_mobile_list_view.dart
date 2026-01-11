import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/contribuicao_model.dart';

class ContribuicaoMobileListView extends StatelessWidget {
  final List<Contribuicao> items;
  final ThemeData theme;
  final Color surfaceColor;
  final Function(Contribuicao) onReceiptPressed;

  const ContribuicaoMobileListView({
    Key? key,
    required this.items,
    required this.theme,
    required this.surfaceColor,
    required this.onReceiptPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return ContribuicaoMobileListViewItem(
            key: ValueKey(item.id),
            item: item,
            theme: theme,
            surfaceColor: surfaceColor,
            onReceiptPressed: () => onReceiptPressed(item),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

class ContribuicaoMobileListViewItem extends StatelessWidget {
  final Contribuicao item;
  final ThemeData theme;
  final Color surfaceColor;
  final VoidCallback onReceiptPressed;

  const ContribuicaoMobileListViewItem({
    Key? key,
    required this.item,
    required this.theme,
    required this.surfaceColor,
    required this.onReceiptPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = item;
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(d.dataRegistro);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.dizimistaNome,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currency.format(d.valor),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment_rounded,
                          size: 14, color: theme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        d.tipo,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 6),
                      Text(
                        d.metodo,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: onReceiptPressed,
                icon: const Icon(Icons.receipt_long_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  foregroundColor: theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
