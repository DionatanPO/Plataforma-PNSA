import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/dizimista_controller.dart';
import '../models/dizimista_model.dart';
import 'status_badge.dart';

// Funções de formatação
String formatCPF(String cpf) {
  if (cpf.isEmpty) return 'CPF não informado';
  final numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
  if (numbers.length != 11) return cpf;
  return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
}

String formatPhone(String phone) {
  if (phone.isEmpty) return '';
  final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (numbers.length == 11) {
    return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
  } else if (numbers.length == 10) {
    return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
  }
  return phone;
}

class DizimistaMobileListView extends StatelessWidget {
  final List<Dizimista> lista;
  final ThemeData theme;
  final Color surfaceColor;
  final Function(Dizimista) onEditPressed;
  final Function(Dizimista) onViewHistoryPressed;

  const DizimistaMobileListView({
    Key? key,
    required this.lista,
    required this.theme,
    required this.surfaceColor,
    required this.onEditPressed,
    required this.onViewHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return DizimistaMobileListViewItem(
            key: ValueKey(lista[index].id),
            dizimista: lista[index],
            theme: theme,
            surfaceColor: surfaceColor,
            onEditPressed: onEditPressed,
            onViewHistoryPressed: onViewHistoryPressed,
          );
        },
        childCount: lista.length,
      ),
    );
  }
}

class DizimistaMobileListViewItem extends StatelessWidget {
  final Dizimista dizimista;
  final ThemeData theme;
  final Color surfaceColor;
  final Function(Dizimista) onEditPressed;
  final Function(Dizimista) onViewHistoryPressed;

  const DizimistaMobileListViewItem({
    Key? key,
    required this.dizimista,
    required this.theme,
    required this.surfaceColor,
    required this.onEditPressed,
    required this.onViewHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = dizimista;
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
          // Informações do Fiel
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      d.nome,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: d.status, compact: true),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Nº Reg: ${d.numeroRegistro}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatCPF(d.cpf),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                final controller = Get.find<DizimistaController>();
                final timeAgo = controller.getTimeSinceLastContribution(d.id);
                final isDark = theme.brightness == Brightness.dark;

                return Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 14,
                      color: timeAgo == 'Nenhuma'
                          ? (isDark ? Colors.orangeAccent : Colors.orange)
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Últ. Contribuição: ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: timeAgo == 'Nenhuma'
                            ? (isDark
                                ? Colors.orangeAccent
                                : Colors.orange.shade800)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onEditPressed(d),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    side:
                        BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => onViewHistoryPressed(d),
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: const Text('Histórico'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withOpacity(
                        theme.brightness == Brightness.dark ? 0.2 : 0.1),
                    foregroundColor: theme.colorScheme.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (Get.find<DizimistaController>().isAuthorizedToDelete) ...[
                const SizedBox(width: 12),
                Material(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _showDeleteConfirmation(context, d),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.red, size: 20),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Dizimista d) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Text('Excluir Fiel?',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja excluir permanentemente este fiel e todo o seu histórico de dízimos?',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoRow('Nome:', d.nome),
                  _infoRow('Registro:', d.numeroRegistro),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ESTA AÇÃO NÃO PODE SER DESFEITA.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar',
                style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Get.find<DizimistaController>()
                  .deleteDizimistaComHistorico(d);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Confirmar Exclusão',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6))),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
